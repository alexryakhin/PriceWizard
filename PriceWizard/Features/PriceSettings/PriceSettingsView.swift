//
//  PriceSettingsView.swift
//  PriceWizard
//
//  Price configuration with base price, index, and apply to App Store Connect.
//

import SwiftUI

/// Territory IDs for United States (Apple may use USA or US)
private let usTerritoryIds = ["USA", "US"]

private struct PricePointOption: Identifiable {
    let id: String
    let customerPrice: String
}

/// Window of US price points around the base (±20) for equalization – avoids ~800 API calls on load.
private let equalizationWindowHalf = 20

/// Returns US price points within ±50 of the base, or all if base not found. Keeps load fast.
private func pricePointsForEqualization(
    usPricePoints: [SubscriptionPricePointResource],
    basePricePoint: SubscriptionPricePointResource?
) -> [SubscriptionPricePointResource] {
    guard let base = basePricePoint, let baseIdx = usPricePoints.firstIndex(where: { $0.id == base.id }) else {
        return usPricePoints
    }
    let lo = max(0, baseIdx - equalizationWindowHalf)
    let hi = min(usPricePoints.count - 1, baseIdx + equalizationWindowHalf)
    return Array(usPricePoints[lo...hi])
}

/// True if the price ends in 9 (e.g. 3.99, 279) – psychological pricing preference.
private func priceEndsInNine(_ price: String) -> Bool {
    let s = price.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
    return s.last == "9"
}

/// Compare two price options for nearest-to-target, preferring prices that end in 9 when close.
private func isPreferredPrice(
    _ a: PricePointOption, _ b: PricePointOption,
    targetLocal: Double
) -> Bool {
    let va = Double(a.customerPrice.replacingOccurrences(of: ",", with: ".")) ?? 0
    let vb = Double(b.customerPrice.replacingOccurrences(of: ",", with: ".")) ?? 0
    let da = abs(va - targetLocal)
    let db = abs(vb - targetLocal)
    let tol = max(targetLocal * 0.005, 0.01)
    if da < db - tol { return true }
    if db < da - tol { return false }
    return priceEndsInNine(a.customerPrice) && !priceEndsInNine(b.customerPrice)
}

private struct PricePickerSheet: View {
    let territoryDisplay: String
    let currency: String
    @Binding var selection: String
    let pricePoints: [PricePointOption]
    let loadPricePoints: () async -> Void
    let isLoading: Bool
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(Loc.PriceSettings.selectPriceFor(territoryDisplay))
                .font(.headline)
                .padding(.top)

            if isLoading {
                ProgressView(Loc.PriceSettings.loadingPricePointsProgress)
                    .padding()
            } else if pricePoints.isEmpty {
                Text(Loc.PriceSettings.noPricePointsAvailable)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                Picker(Loc.PriceSettings.priceCurrency(currency), selection: $selection) {
                    ForEach(pricePoints) { opt in
                        Text("\(opt.customerPrice) \(currency)")
                            .tag(opt.id)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 200)
                .padding()
            }

            Spacer()

            Button(Loc.PriceSettings.done) {
                onDismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom)
        }
        .frame(width: 320, height: 220)
        .task {
            if pricePoints.isEmpty { await loadPricePoints() }
        }
    }
}

struct PriceSettingsView: View {
    @Bindable var authState: AuthState
    let subscription: SubscriptionResource?
    @State private var usPricePoints: [SubscriptionPricePointResource] = []
    @State private var selectedBasePricePoint: SubscriptionPricePointResource?
    @State private var equalizations: [SubscriptionPricePointResource] = []
    @State private var territoryMap: [String: TerritoryInfo] = [:]
    @State private var exchangeRates: [String: Double] = [:]
    @State private var existingPrices: [SubscriptionPriceResource] = []
    @State private var indexMode: IndexMode = .appleEqualization
    @State private var territoryIndices: [String: Double] = [:]
    @State private var pricePointsByTerritory: [String: [PricePointOption]] = [:]
    @State private var selectedPricePointByTerritory: [String: String] = [:]
    @State private var currentPriceByTerritory: [String: String] = [:]
    @State private var isLoading = false
    @State private var isLoadingCustomTiers = false
    @State private var tierLoadProgress: Double = 0
    @State private var tierLoadCurrent: Int = 0
    @State private var tierLoadTotal: Int = 0
    @State private var territoryIdForPriceSheet: String?
    @State private var isLoadingPriceSheet = false
    @State private var isApplying = false
    @State private var preserveCurrentPriceForExisting = false
    @State private var priceStartDate = Date()
    @State private var applyProgress: Double = 0
    @State private var errorMessage: String?
    @State private var successMessage: String?

    enum IndexMode: String, CaseIterable {
        case appleEqualization = "Apple Equalization"
        case netflix = "Netflix"
        case spotify = "Spotify"
    }

    private var usesCustomIndex: Bool {
        switch indexMode {
        case .appleEqualization: return false
        case .netflix, .spotify: return true
        }
    }

    /// Earliest start date among existing prices that is today or in the future (UTC). Nil if none.
    private var nextScheduledStartDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let todayStr = formatter.string(from: Date())
        var earliest: Date?
        for price in existingPrices {
            guard let startStr = price.attributes?.startDate else { continue }
            let trimmed = String(startStr.prefix(10))
            guard let date = formatter.date(from: trimmed), trimmed >= todayStr else { continue }
            if earliest == nil || date < earliest! {
                earliest = date
            }
        }
        return earliest
    }

    /// True if the selected start date is the same day (UTC) as an existing scheduled price change.
    private var isStartDateConflictingWithScheduled: Bool {
        guard let next = nextScheduledStartDate else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: priceStartDate) == formatter.string(from: next)
    }

    private var canApply: Bool {
        guard selectedBasePricePoint != nil, !isApplying else { return false }
        guard !equalizations.isEmpty else { return false }
        guard !isLoadingCustomTiers else { return false }
        guard !isStartDateConflictingWithScheduled else { return false }
        return previewRows.allSatisfy { !$0.pricePointId.isEmpty }
    }

    var body: some View {
        Group {
            if subscription == nil {
                ContentUnavailableView(
                    Loc.PriceSettings.selectSubscription,
                    systemImage: "dollarsign.circle",
                    description: Text(Loc.PriceSettings.selectSubscriptionDescription)
                )
            } else {
                Form {
                    Section(Loc.PriceSettings.basePrice) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                Text(Loc.PriceSettings.loadingPricePoints)
                                    .foregroundStyle(.secondary)
                            }
                        } else if usPricePoints.isEmpty {
                            Text(Loc.PriceSettings.noPricePointsForSubscription)
                                .foregroundStyle(.secondary)
                        } else {
                            Picker(Loc.PriceSettings.price, selection: $selectedBasePricePoint) {
                                Text(Loc.PriceSettings.select).tag(nil as SubscriptionPricePointResource?)
                                ForEach(usPricePoints, id: \.id) { pp in
                                    Text(pp.attributes.customerPrice ?? Loc.Subscriptions.unknown).tag(pp as SubscriptionPricePointResource?)
                                }
                            }
                            .onChange(of: selectedBasePricePoint) { _, new in
                                if let id = new?.id {
                                    Task { await loadEqualizations(pricePointId: id) }
                                } else {
                                    equalizations = []
                                    territoryMap = [:]
                                    pricePointsByTerritory = [:]
                                    selectedPricePointByTerritory = [:]
                                }
                            }
                        }
                    }

                    Section(Loc.PriceSettings.indexMode) {
                        Picker(Loc.PriceSettings.mode, selection: $indexMode) {
                            ForEach(IndexMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .onChange(of: indexMode) { _, new in
                            switch new {
                            case .netflix:
                                territoryIndices = TerritoryIndices.indices(for: .netflix)
                            case .spotify:
                                territoryIndices = TerritoryIndices.indices(for: .spotify)
                            case .appleEqualization:
                                break
                            }
                            if !territoryMap.isEmpty {
                                Task { await resetAndReapplyPrices() }
                            }
                        }
                    }

                    if !equalizations.isEmpty {
                        Section(Loc.PriceSettings.preview) {
                            if isLoadingCustomTiers {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        ProgressView(value: tierLoadProgress, total: 1)
                                            .frame(maxWidth: 200)
                                        if tierLoadTotal > 0 {
                                            Text(Loc.PriceSettings.tierProgress(String(tierLoadCurrent), String(tierLoadTotal)))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .monospacedDigit()
                                        }
                                    }
                                    Text(Loc.PriceSettings.loadingPriceTiers)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            Table(previewRows) {
                                TableColumn(Loc.PriceSettings.territory) { row in
                                    if let territory = Territory(apiCode: row.territoryIdForAPI) {
                                        HStack(spacing: 6) {
                                            territory.image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                                .frame(width: 24, height: 24)
                                            Text(territory.displayName)
                                        }
                                    } else {
                                        Text(row.territoryDisplay)
                                    }
                                }
                                TableColumn(Loc.PriceSettings.currency) { row in
                                    Text(row.currency)
                                }
                                TableColumn(Loc.PriceSettings.currentPrice) { row in
                                    Text(row.currentPrice)
                                }
                                TableColumn(Loc.PriceSettings.newPrice) { row in
                                    Button {
                                        territoryIdForPriceSheet = row.territoryIdForAPI
                                    } label: {
                                        HStack(spacing: 2) {
                                            Text(row.price)
                                            priceChangeIcon(
                                                newPrice: row.price,
                                                currentPrice: row.currentPrice
                                            )
                                            Spacer()
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        .contentShape(.rect)
                                    }
                                    .buttonStyle(.plain)
                                }
                                TableColumn(Loc.PriceSettings.newPriceUSD) { row in
                                    Text(row.priceUSD)
                                }
                            }
                        }
                    }

                    Section(Loc.PriceSettings.priceChangeOptions) {
                        Toggle(Loc.PriceSettings.preserveCurrentPrice, isOn: $preserveCurrentPriceForExisting)
                        DatePicker(Loc.PriceSettings.startDate, selection: $priceStartDate, displayedComponents: .date)
                        if let next = nextScheduledStartDate {
                            let formatted = next.formatted(date: .abbreviated, time: .omitted)
                            Text(Loc.PriceSettings.nextScheduledChange(formatted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if !existingPrices.isEmpty {
                            Text(Loc.PriceSettings.noFutureScheduledChanges)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if isStartDateConflictingWithScheduled {
                            Label(Loc.PriceSettings.startDateConflict, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }

                    Section {
                        Button(Loc.PriceSettings.applyToAppStoreConnect) {
                            Task { await applyPrices() }
                        }
                        .disabled(!canApply)
                        if isApplying {
                            ProgressView(value: applyProgress)
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .navigationTitle(subscription?.attributes.name ?? "Price Settings")
        .task(id: subscription?.id) {
            await loadData()
        }
        .alert(Loc.PriceSettings.error, isPresented: .constant(errorMessage != nil)) {
            Button(Loc.PriceSettings.ok) { errorMessage = nil }
        } message: {
            if let err = errorMessage {
                Text(err)
            }
        }
        .overlay {
            if let success = successMessage {
                Text(success)
                    .padding()
                    .background(.green.opacity(0.9))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .task(id: successMessage) {
            guard successMessage != nil else { return }
            try? await Task.sleep(for: .seconds(3))
            successMessage = nil
        }
        .sheet(item: Binding(
            get: { territoryIdForPriceSheet.map { PriceSheetItem(territoryId: $0) } },
            set: { territoryIdForPriceSheet = $0?.territoryId }
        )) { item in
            PricePickerSheet(
                territoryDisplay: Territory(apiCode: item.territoryId)?.displayName ?? TerritoryNames.displayName(for: item.territoryId),
                currency: territoryMap[item.territoryId]?.currency ?? "—",
                selection: Binding(
                    get: { selectedPricePointByTerritory[item.territoryId] ?? "" },
                    set: { new in
                        var d = selectedPricePointByTerritory
                        d[item.territoryId] = new
                        selectedPricePointByTerritory = d
                    }
                ),
                pricePoints: pricePointsByTerritory[item.territoryId] ?? [],
                loadPricePoints: { await loadPricePointsForTerritory(item.territoryId) },
                isLoading: isLoadingPriceSheet,
                onDismiss: { territoryIdForPriceSheet = nil }
            )
        }
    }

    private struct PriceSheetItem: Identifiable {
        let territoryId: String
        var id: String { territoryId }
    }

    private struct TerritoryInfo {
        let id: String
        let currency: String
        let displayName: String
    }

    private var baseUSD: Double? {
        guard let pp = selectedBasePricePoint, let s = pp.attributes.customerPrice else { return nil }
        return Double(s.replacingOccurrences(of: ",", with: "."))
    }

    private var previewRows: [PreviewRow] {
        let territoryIds = Array(territoryMap.keys)
        return territoryIds.compactMap { tid -> PreviewRow? in
            let info = territoryMap[tid]
            let currency = info?.currency ?? "—"
            let pricePointId = selectedPricePointByTerritory[tid]
                ?? equalizations.first(where: { $0.relationships?.territory?.data?.id == tid })?.id ?? ""
            let points = pricePointsByTerritory[tid] ?? []
            let opt = points.first(where: { $0.id == pricePointId })
            let eqPrice = equalizations.first(where: { $0.relationships?.territory?.data?.id == tid })?.attributes.customerPrice
            let priceStr = opt?.customerPrice ?? eqPrice ?? "—"
            let priceUSD = formatUSD(priceStr: priceStr, currency: currency)
            let index = usesCustomIndex ? (territoryIndices[tid] ?? 1.0) : 1.0
            let currentPrice = currentPriceByTerritory[tid] ?? "—"
            return PreviewRow(
                territoryIdForAPI: tid,
                territoryDisplay: TerritoryNames.displayName(for: tid),
                currentPrice: currentPrice,
                currency: currency,
                price: priceStr,
                priceUSD: priceUSD,
                pricePointId: pricePointId,
                index: index
            )
        }
        .sorted { $0.territoryDisplay.localizedStandardCompare($1.territoryDisplay) == .orderedAscending }
    }

    @ViewBuilder
    private func priceChangeIcon(newPrice: String, currentPrice: String) -> some View {
        let newVal = Double(newPrice.replacingOccurrences(of: ",", with: "."))
        let curVal = Double(currentPrice.replacingOccurrences(of: ",", with: "."))
        if let n = newVal, let c = curVal {
            if abs(n - c) < 0.001 {
                Image(systemName: "equal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if n > c {
                Image(systemName: "arrow.up")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "arrow.down")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func formatUSD(priceStr: String, currency: String) -> String {
        guard let amount = Double(priceStr.replacingOccurrences(of: ",", with: ".")) else { return "—" }
        guard let usd = ExchangeRateService.toUSD(amount: amount, currency: currency, rates: exchangeRates) else {
            return currency == "USD" ? priceStr : "—"
        }
        return String(format: "%.2f", usd)
    }

    private struct PreviewRow: Identifiable {
        var id: String { pricePointId.isEmpty ? territoryIdForAPI : pricePointId }
        let territoryIdForAPI: String
        let territoryDisplay: String
        let currentPrice: String
        let currency: String
        let price: String
        let priceUSD: String
        let pricePointId: String
        let index: Double
    }

    private func resetContentState() {
        usPricePoints = []
        selectedBasePricePoint = nil
        equalizations = []
        territoryMap = [:]
        existingPrices = []
        pricePointsByTerritory = [:]
        selectedPricePointByTerritory = [:]
        currentPriceByTerritory = [:]
        territoryIdForPriceSheet = nil
        successMessage = nil
    }

    private func loadData() async {
        resetContentState()
        guard let api = authState.api, let subId = subscription?.id else { return }
        // Don't clear equalizations cache – keep per–price-point cache so switching base price reuses cached tiers.
        isLoading = true
        errorMessage = nil
        do {
            // Fetch all price points (no territory filter) - API may use USA or US for US
            let allPoints = try await api.getSubscriptionPricePoints(subscriptionId: subId, territoryId: "USA", limit: 800)
            // Filter for US territory (USD) – match territory id from relationships
            let usPoints = allPoints.filter { pp in
                guard let tid = pp.relationships?.territory?.data?.id else { return false }
                return usTerritoryIds.contains(tid)
            }
            // Filter to .99 (any price) and .49 when price < 50 – reduces 800+ options. Match both "." and "," decimal.
            let usFiltered99 = usPoints.filter { pp in
                guard let price = pp.attributes.customerPrice else { return false }
                let trimmed = price.trimmingCharacters(in: .whitespaces)
                let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
                let value = Double(normalized)
                let is99 = trimmed.hasSuffix(".99") || trimmed.hasSuffix(",99")
                let is49Under20 = (trimmed.hasSuffix(".49") || trimmed.hasSuffix(",49")) && (value ?? 0) < 20
                return is99 || is49Under20
            }
            // Fall back to all US points if filter yields none (e.g. unusual locale format)
            usPricePoints = usFiltered99.isEmpty ? usPoints : usFiltered99
            // If still no US points, use all points so user can still pick a base price
            if usPricePoints.isEmpty && !allPoints.isEmpty {
                usPricePoints = allPoints
            }
            let pricesResponse = try await api.getSubscriptionPricesResponse(subscriptionId: subId)
            existingPrices = pricesResponse.data
            currentPriceByTerritory = pricesResponse.currentPriceByTerritory()

            let usCurrentPrice = usTerritoryIds.lazy.compactMap { currentPriceByTerritory[$0] }.first
            let baseToSelect = usCurrentPrice.flatMap { priceStr in
                let target = Double(priceStr.replacingOccurrences(of: ",", with: "."))
                return usPricePoints.first(where: { pp in
                    guard let v = Double(pp.attributes.customerPrice?.replacingOccurrences(of: ",", with: ".") ?? "") else { return false }
                    return target != nil && abs((target ?? 0) - v) < 0.01
                })
            } ?? usPricePoints.first
            selectedBasePricePoint = baseToSelect
            if let id = baseToSelect?.id {
                await loadEqualizations(pricePointId: id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadEqualizations(pricePointId: String) async {
        guard let api = authState.api else { return }
        do {
            let (points, territories) = try await api.getPricePointEqualizations(pricePointId: pricePointId)
            guard selectedBasePricePoint?.id == pricePointId else { return }
            equalizations = points
            territoryMap = Dictionary(uniqueKeysWithValues: territories.map { t in
                let name = TerritoryNames.displayName(for: t.id)
                return (t.id, TerritoryInfo(id: t.id, currency: t.attributes.currency ?? "—", displayName: name))
            })
            // Equalizations API often omits the source territory (US). Ensure United States is in the list.
            if let base = selectedBasePricePoint, !usTerritoryIds.contains(where: { territoryMap[$0] != nil }) {
                let usId = usTerritoryIds.first!
                territoryMap[usId] = TerritoryInfo(id: usId, currency: "USD", displayName: TerritoryNames.displayName(for: usId))
                let usEntry = SubscriptionPricePointResource(
                    type: "subscriptionPricePoints",
                    id: base.id,
                    attributes: base.attributes,
                    relationships: SubscriptionPricePointResource.SubscriptionPricePointRelationships(
                        territory: RelationshipData(data: ResourceIdentifier(type: "territories", id: usId))
                    )
                )
                equalizations.insert(usEntry, at: 0)
            }
            if exchangeRates.isEmpty {
                exchangeRates = await ExchangeRateService.fetchRatesFromUSD()
            }
            guard selectedBasePricePoint?.id == pricePointId else { return }
            await resetAndReapplyPrices(basePricePointId: pricePointId)
        } catch {
            guard selectedBasePricePoint?.id == pricePointId else { return }
            errorMessage = error.localizedDescription
            equalizations = []
            territoryMap = [:]
        }
    }

    private func resetAndReapplyPrices(basePricePointId: String? = nil) async {
        let expectedId = basePricePointId ?? selectedBasePricePoint?.id
        pricePointsByTerritory = [:]
        selectedPricePointByTerritory = [:]

        guard let api = authState.api else { return }
        let territoryIds = Array(territoryMap.keys)
        guard !territoryIds.isEmpty else { return }
        guard selectedBasePricePoint?.id == expectedId else { return }

        if indexMode == .appleEqualization {
            // Use equalizations immediately – base price section appears right away.
            var selections: [String: String] = [:]
            for pp in equalizations {
                guard let tid = pp.relationships?.territory?.data?.id else { continue }
                selections[tid] = pp.id
            }
            selectedPricePointByTerritory = selections
            pricePointsByTerritory = Dictionary(uniqueKeysWithValues: equalizations.compactMap { pp -> (String, [PricePointOption])? in
                guard let tid = pp.relationships?.territory?.data?.id else { return nil }
                let opt = PricePointOption(id: pp.id, customerPrice: pp.attributes.customerPrice ?? "—")
                return (tid, [opt])
            })
            // Fetch full tier options in background – updates picker when done.
            if let baseId = expectedId {
                Task { await loadFullTiersForAppleEqualization(basePricePointId: baseId) }
            }
            return
        }

        guard let base = baseUSD, base > 0 else { return }
        guard selectedBasePricePoint?.id == expectedId else { return }
        let pointsToEqualize = pricePointsForEqualization(
            usPricePoints: usPricePoints,
            basePricePoint: selectedBasePricePoint
        )
        tierLoadTotal = pointsToEqualize.count
        tierLoadCurrent = 0
        tierLoadProgress = 0
        isLoadingCustomTiers = true
        defer {
            isLoadingCustomTiers = false
            tierLoadTotal = 0
            tierLoadCurrent = 0
            tierLoadProgress = 0
        }

        // Use equalizations for ±50 US price points around base – avoids ~800 API calls. Cached per price point ID.
        var pointsByTerritory: [String: [PricePointOption]] = [:]
        for tid in territoryIds {
            pointsByTerritory[tid] = []
        }
        for (idx, pp) in pointsToEqualize.enumerated() {
            guard selectedBasePricePoint?.id == expectedId else { return }
            tierLoadCurrent = idx + 1
            tierLoadProgress = Double(idx + 1) / Double(pointsToEqualize.count)
            if (idx + 1) % 10 == 0 || idx == 0 {
                debugPrint("[PriceWizard] Loading price tiers \(idx + 1)/\(pointsToEqualize.count)")
            }
            do {
                let (eqPoints, _) = try await api.getPricePointEqualizations(pricePointId: pp.id, limit: 200)
                for eq in eqPoints {
                    guard let tid = eq.relationships?.territory?.data?.id else { continue }
                    let opt = PricePointOption(id: eq.id, customerPrice: eq.attributes.customerPrice ?? "—")
                    if pointsByTerritory[tid]?.contains(where: { $0.id == opt.id }) == false {
                        pointsByTerritory[tid, default: []].append(opt)
                    }
                }
            } catch {
                continue
            }
        }
        pricePointsByTerritory = pointsByTerritory

        var selections: [String: String] = [:]
        for tid in territoryMap.keys {
            let info = territoryMap[tid]
            let currency = info?.currency ?? "USD"
            let index = territoryIndices[tid] ?? 1.0
            let targetUSD = base * index
            let rate = currency == "USD" ? 1.0 : (exchangeRates[currency.uppercased()] ?? 1.0)
            let targetLocal = targetUSD * rate
            let points = pricePointsByTerritory[tid] ?? []
            let nearest = points.min(by: { isPreferredPrice($0, $1, targetLocal: targetLocal) })
            if let opt = nearest {
                selections[tid] = opt.id
            }
        }
        guard selectedBasePricePoint?.id == expectedId else { return }
        selectedPricePointByTerritory = selections
        debugPrint("[PriceWizard] Finished loading price tiers (\(pointsToEqualize.count) price points)")
    }

    private func loadFullTiersForAppleEqualization(basePricePointId: String) async {
        guard indexMode == .appleEqualization, let api = authState.api else { return }
        let territoryIds = Array(territoryMap.keys)
        guard !territoryIds.isEmpty else { return }
        guard selectedBasePricePoint?.id == basePricePointId else { return }
        let pointsToEqualize = pricePointsForEqualization(usPricePoints: usPricePoints, basePricePoint: selectedBasePricePoint)
        tierLoadTotal = pointsToEqualize.count
        tierLoadCurrent = 0
        tierLoadProgress = 0
        isLoadingCustomTiers = true
        defer {
            isLoadingCustomTiers = false
            tierLoadTotal = 0
            tierLoadCurrent = 0
            tierLoadProgress = 0
        }
        var pointsByTerritory: [String: [PricePointOption]] = [:]
        for tid in territoryIds { pointsByTerritory[tid] = [] }
        for (idx, pp) in pointsToEqualize.enumerated() {
            guard selectedBasePricePoint?.id == basePricePointId else { return }
            tierLoadCurrent = idx + 1
            tierLoadProgress = Double(idx + 1) / Double(pointsToEqualize.count)
            if (idx + 1) % 10 == 0 || idx == 0 {
                debugPrint("[PriceWizard] Loading price tiers \(idx + 1)/\(pointsToEqualize.count)")
            }
            do {
                let (eqPoints, _) = try await api.getPricePointEqualizations(pricePointId: pp.id, limit: 200)
                for eq in eqPoints {
                    guard let tid = eq.relationships?.territory?.data?.id else { continue }
                    let opt = PricePointOption(id: eq.id, customerPrice: eq.attributes.customerPrice ?? "—")
                    if pointsByTerritory[tid]?.contains(where: { $0.id == opt.id }) == false {
                        pointsByTerritory[tid, default: []].append(opt)
                    }
                }
            } catch { continue }
        }
        guard selectedBasePricePoint?.id == basePricePointId else { return }
        pricePointsByTerritory = pointsByTerritory
        debugPrint("[PriceWizard] Finished loading price tiers (\(pointsToEqualize.count) price points)")
    }

    private func loadPricePointsForTerritory(_ territoryId: String) async {
        // Do NOT fetch getSubscriptionPricePoints per territory – it returns period-agnostic tiers
        // (e.g. monthly $24.9 max) even for yearly subscriptions. All period-correct price points
        // come from equalizations, which are already in pricePointsByTerritory.
        guard pricePointsByTerritory[territoryId]?.isEmpty == true else { return }
        // If we have no points for this territory (equalizations failed or territory not covered),
        // we cannot safely load more – getSubscriptionPricePoints would return wrong period.
        isLoadingPriceSheet = false
    }

    private func applyPrices() async {
        guard let api = authState.api, let subId = subscription?.id else { return }
        isApplying = true
        successMessage = nil
        errorMessage = nil
        let rows = previewRows
        let total = Double(rows.count)
        var completed = 0.0
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let startDateStr = formatter.string(from: priceStartDate)

        do {
            var appliedCount = 0
            for row in rows {
                let currentStr = currentPriceByTerritory[row.territoryIdForAPI] ?? ""
                let newStr = row.price
                let currentVal = Double(currentStr.replacingOccurrences(of: ",", with: "."))
                let newVal = Double(newStr.replacingOccurrences(of: ",", with: "."))
                let alreadySame = currentVal != nil && newVal != nil && abs((currentVal ?? 0) - (newVal ?? 0)) < 0.001
                if !alreadySame {
                    try await api.createSubscriptionPrice(
                        subscriptionId: subId,
                        pricePointId: row.pricePointId,
                        territoryId: row.territoryIdForAPI,
                        startDate: startDateStr,
                        preserveCurrentPrice: preserveCurrentPriceForExisting ? true : nil
                    )
                    appliedCount += 1
                }
                completed += 1
                applyProgress = completed / total
            }
            let skipped = rows.count - appliedCount
            if skipped > 0 {
                successMessage = "Applied \(appliedCount) prices (\(skipped) already set, skipped)"
            } else {
                successMessage = "Applied \(rows.count) prices successfully"
            }
            for row in rows {
                currentPriceByTerritory[row.territoryIdForAPI] = row.price
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isApplying = false
        applyProgress = 0
    }
}
