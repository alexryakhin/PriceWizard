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
            Text("Select Price for \(territoryDisplay)")
                .font(.headline)
                .padding(.top)

            if isLoading {
                ProgressView("Loading price points…")
                    .padding()
            } else if pricePoints.isEmpty {
                Text("No price points available")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                Picker("Price (\(currency))", selection: $selection) {
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

            Button("Done") {
                onDismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom)
        }
        .frame(width: 320, height: 220)
        .task {
            if pricePoints.isEmpty || pricePoints.count == 1 {
                await loadPricePoints()
            }
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
    @State private var territoryIdForPriceSheet: String?
    @State private var isLoadingPriceSheet = false
    @State private var isApplying = false
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

    private var canApply: Bool {
        guard selectedBasePricePoint != nil, !isApplying else { return false }
        guard !equalizations.isEmpty else { return false }
        guard !isLoadingCustomTiers else { return false }
        return previewRows.allSatisfy { !$0.pricePointId.isEmpty }
    }

    var body: some View {
        Group {
            if subscription == nil {
                ContentUnavailableView(
                    "Select a Subscription",
                    systemImage: "dollarsign.circle",
                    description: Text("Choose a subscription from the list to configure its prices.")
                )
            } else {
                Form {
                    Section("Base Price") {
                        if isLoading {
                            HStack {
                                ProgressView()
                                Text("Loading price points…")
                                    .foregroundStyle(.secondary)
                            }
                        } else if usPricePoints.isEmpty {
                            Text("No price points available for this subscription.")
                                .foregroundStyle(.secondary)
                        } else {
                            Picker("Price", selection: $selectedBasePricePoint) {
                                Text("Select…").tag(nil as SubscriptionPricePointResource?)
                                ForEach(usPricePoints, id: \.id) { pp in
                                    Text(pp.attributes.customerPrice ?? "Unknown").tag(pp as SubscriptionPricePointResource?)
                                }
                            }
                            .onChange(of: selectedBasePricePoint) { _, new in
                                if let id = new?.id {
                                    Task { await loadEqualizations(pricePointId: id) }
                                } else {
                                    equalizations = []
                                }
                            }
                        }
                    }

                    Section("Index Mode") {
                        Picker("Mode", selection: $indexMode) {
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
                        Section("Preview") {
                            if isLoadingCustomTiers {
                                HStack {
                                    ProgressView()
                                    Text("Loading price tiers…")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Table(previewRows) {
                                TableColumn("Territory") { row in
                                    Text(row.territoryDisplay)
                                }
                                TableColumn("Currency") { row in
                                    Text(row.currency)
                                }
                                TableColumn("Current price") { row in
                                    Text(row.currentPrice)
                                }
                                TableColumn("New Price") { row in
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
                                TableColumn("New Price (USD)") { row in
                                    Text(row.priceUSD)
                                }
                                if usesCustomIndex {
                                    TableColumn("Index") { row in
                                        Text(String(format: "%.2f", row.index))
                                    }
                                }
                            }
                        }
                    }

                    Section {
                        Button("Apply to App Store Connect") {
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
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
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
        .sheet(item: Binding(
            get: { territoryIdForPriceSheet.map { PriceSheetItem(territoryId: $0) } },
            set: { territoryIdForPriceSheet = $0?.territoryId }
        )) { item in
            PricePickerSheet(
                territoryDisplay: TerritoryNames.displayName(for: item.territoryId),
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

    private func loadData() async {
        guard let api = authState.api, let subId = subscription?.id else {
            usPricePoints = []
            equalizations = []
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            // Fetch all price points (no territory filter) - API may use USA or US for US
            let allPoints = try await api.getSubscriptionPricePoints(subscriptionId: subId, territoryId: nil, limit: 800)
            // Filter for US territory (USD) - match territory id from relationships
            usPricePoints = allPoints.filter { pp in
                guard let tid = pp.relationships?.territory?.data?.id else { return false }
                return usTerritoryIds.contains(tid)
            }
            // If no US points found, use all points (user can still pick a base price)
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
            equalizations = points
            territoryMap = Dictionary(uniqueKeysWithValues: territories.map { t in
                let name = TerritoryNames.displayName(for: t.id)
                return (t.id, TerritoryInfo(id: t.id, currency: t.attributes.currency ?? "—", displayName: name))
            })
            if exchangeRates.isEmpty {
                exchangeRates = await ExchangeRateService.fetchRatesFromUSD()
            }
            await resetAndReapplyPrices()
        } catch {
            errorMessage = error.localizedDescription
            equalizations = []
            territoryMap = [:]
        }
    }

    private func resetAndReapplyPrices() async {
        pricePointsByTerritory = [:]
        selectedPricePointByTerritory = [:]

        if indexMode == .appleEqualization {
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
            return
        }

        guard let api = authState.api, let subId = subscription?.id else { return }
        guard let base = baseUSD, base > 0 else { return }
        let territoryIds = Array(territoryMap.keys)
        guard !territoryIds.isEmpty else { return }

        isLoadingCustomTiers = true
        var result: [String: [PricePointOption]] = [:]
        let concurrencyLimit = 8
        for chunkStart in stride(from: 0, to: territoryIds.count, by: concurrencyLimit) {
            let chunk = Array(territoryIds[chunkStart..<min(chunkStart + concurrencyLimit, territoryIds.count)])
            await withTaskGroup(of: (String, [PricePointOption]).self) { group in
                for tid in chunk {
                    group.addTask {
                        do {
                            let points = try await api.getSubscriptionPricePoints(subscriptionId: subId, territoryId: tid, limit: 200)
                            let opts = points.map { PricePointOption(id: $0.id, customerPrice: $0.attributes.customerPrice ?? "—") }
                            return (tid, opts)
                        } catch {
                            return (tid, [])
                        }
                    }
                }
                for await (tid, opts) in group {
                    result[tid] = opts
                }
            }
        }
        pricePointsByTerritory = result

        var selections: [String: String] = [:]
        for tid in territoryMap.keys {
            let info = territoryMap[tid]
            let currency = info?.currency ?? "USD"
            let index = territoryIndices[tid] ?? 1.0
            let targetUSD = base * index
            let rate = currency == "USD" ? 1.0 : (exchangeRates[currency.uppercased()] ?? 1.0)
            let targetLocal = targetUSD * rate
            let points = result[tid] ?? []
            let nearest = points.min(by: { isPreferredPrice($0, $1, targetLocal: targetLocal) })
            if let opt = nearest {
                selections[tid] = opt.id
            }
        }
        selectedPricePointByTerritory = selections
        isLoadingCustomTiers = false
    }

    private func loadPricePointsForTerritory(_ territoryId: String) async {
        guard pricePointsByTerritory[territoryId] == nil || pricePointsByTerritory[territoryId]?.count == 1 else { return }
        guard let api = authState.api, let subId = subscription?.id else { return }
        isLoadingPriceSheet = true
        do {
            let points = try await api.getSubscriptionPricePoints(subscriptionId: subId, territoryId: territoryId, limit: 200)
            let opts = points.map { PricePointOption(id: $0.id, customerPrice: $0.attributes.customerPrice ?? "—") }
            pricePointsByTerritory[territoryId] = opts
            if selectedPricePointByTerritory[territoryId] == nil || !opts.contains(where: { $0.id == selectedPricePointByTerritory[territoryId] }) {
                var d = selectedPricePointByTerritory
                if usesCustomIndex, let base = baseUSD, base > 0, let info = territoryMap[territoryId] {
                    let currency = info.currency
                    let index = territoryIndices[territoryId] ?? 1.0
                    let targetUSD = base * index
                    let rate = currency == "USD" ? 1.0 : (exchangeRates[currency.uppercased()] ?? 1.0)
                    let targetLocal = targetUSD * rate
                    let nearest = opts.min(by: { isPreferredPrice($0, $1, targetLocal: targetLocal) })
                    d[territoryId] = nearest?.id
                } else if let first = opts.first {
                    d[territoryId] = first.id
                }
                selectedPricePointByTerritory = d
            }
        } catch {
            errorMessage = error.localizedDescription
        }
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
        do {
            for row in rows {
                try await api.createSubscriptionPrice(
                    subscriptionId: subId,
                    pricePointId: row.pricePointId,
                    territoryId: row.territoryIdForAPI
                )
                completed += 1
                applyProgress = completed / total
            }
            successMessage = "Applied \(rows.count) prices successfully"
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
