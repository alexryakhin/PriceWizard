//
//  PriceSettingsView.swift
//  PriceWizard
//
//  Price configuration with base price, index, and apply to App Store Connect.
//

import SwiftUI

/// Territory IDs for United States (Apple may use USA or US)
private let usTerritoryIds = ["USA", "US"]

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
    @State private var pricePointsByTerritory: [String: [SubscriptionPricePointResource]] = [:]
    @State private var isLoading = false
    @State private var isLoadingCustomTiers = false
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
        if usesCustomIndex {
            guard !isLoadingCustomTiers else { return false }
            let rows = previewRows
            return rows.allSatisfy { !$0.pricePointId.isEmpty }
        }
        return true
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
                            if (new == .netflix || new == .spotify) && !territoryMap.isEmpty {
                                Task { await loadPricePointsForCustomIndex() }
                            }
                        }
                    }

                    if !equalizations.isEmpty {
                        Section("Preview") {
                            if usesCustomIndex && isLoadingCustomTiers {
                                HStack {
                                    ProgressView()
                                    Text("Loading price tiers for custom index…")
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
                                TableColumn("New Price") { row in
                                    Text(row.price)
                                }
                                TableColumn("Price (USD)") { row in
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
        if usesCustomIndex {
            return previewRowsForCustomIndex
        }
        return equalizations
            .filter { pp in pp.relationships?.territory?.data?.id != nil }
            .map { pp in
                let tid = pp.relationships!.territory!.data!.id
                let info = territoryMap[tid]
                let territoryName = TerritoryNames.displayName(for: tid)
                let currency = info?.currency ?? "—"
                let priceStr = pp.attributes.customerPrice ?? "—"
                let priceUSD = formatUSD(priceStr: priceStr, currency: currency)
                return PreviewRow(
                    territoryIdForAPI: tid,
                    territoryDisplay: territoryName,
                    currency: currency,
                    price: priceStr,
                    priceUSD: priceUSD,
                    pricePointId: pp.id,
                    index: 1.0
                )
            }
            .sorted { $0.territoryDisplay.localizedStandardCompare($1.territoryDisplay) == .orderedAscending }
    }

    private var previewRowsForCustomIndex: [PreviewRow] {
        guard let base = baseUSD, base > 0 else {
            return territoryMap.keys.map { tid in
                let info = territoryMap[tid]
                return PreviewRow(
                    territoryIdForAPI: tid,
                    territoryDisplay: TerritoryNames.displayName(for: tid),
                    currency: info?.currency ?? "—",
                    price: "—",
                    priceUSD: "—",
                    pricePointId: "",
                    index: territoryIndices[tid] ?? 1.0
                )
            }
            .sorted { $0.territoryDisplay.localizedStandardCompare($1.territoryDisplay) == .orderedAscending }
        }
        return territoryMap.keys.compactMap { tid -> PreviewRow? in
            let info = territoryMap[tid]
            let currency = info?.currency ?? "USD"
            let index = territoryIndices[tid] ?? 1.0
            let targetUSD = base * index
            let rate = currency == "USD" ? 1.0 : (exchangeRates[currency.uppercased()] ?? 1.0)
            let targetLocal = targetUSD * rate
            let points = pricePointsByTerritory[tid] ?? []
            let nearest = points.min(by: { a, b in
                let va = Double(a.attributes.customerPrice?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0
                let vb = Double(b.attributes.customerPrice?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0
                return abs(va - targetLocal) < abs(vb - targetLocal)
            })
            guard let pp = nearest else {
                return PreviewRow(
                    territoryIdForAPI: tid,
                    territoryDisplay: TerritoryNames.displayName(for: tid),
                    currency: currency,
                    price: "—",
                    priceUSD: "—",
                    pricePointId: "",
                    index: index
                )
            }
            let priceStr = pp.attributes.customerPrice ?? "—"
            let priceUSD = formatUSD(priceStr: priceStr, currency: currency)
            return PreviewRow(
                territoryIdForAPI: tid,
                territoryDisplay: TerritoryNames.displayName(for: tid),
                currency: currency,
                price: priceStr,
                priceUSD: priceUSD,
                pricePointId: pp.id,
                index: index
            )
        }
        .sorted { $0.territoryDisplay.localizedStandardCompare($1.territoryDisplay) == .orderedAscending }
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
            existingPrices = try await api.getSubscriptionPrices(subscriptionId: subId)
            if selectedBasePricePoint == nil, let first = usPricePoints.first {
                selectedBasePricePoint = first
                await loadEqualizations(pricePointId: first.id)
            } else if let selected = selectedBasePricePoint, usPricePoints.contains(where: { $0.id == selected.id }) {
                await loadEqualizations(pricePointId: selected.id)
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
            pricePointsByTerritory = [:]
            if indexMode == .netflix || indexMode == .spotify {
                await loadPricePointsForCustomIndex()
            }
        } catch {
            errorMessage = error.localizedDescription
            equalizations = []
            territoryMap = [:]
        }
    }

    private func loadPricePointsForCustomIndex() async {
        guard let api = authState.api, let subId = subscription?.id else { return }
        let territoryIds = Array(territoryMap.keys)
        guard !territoryIds.isEmpty else { return }
        isLoadingCustomTiers = true
        var result: [String: [SubscriptionPricePointResource]] = [:]
        await withTaskGroup(of: (String, [SubscriptionPricePointResource]).self) { group in
            for tid in territoryIds {
                group.addTask {
                    do {
                        let points = try await api.getSubscriptionPricePoints(subscriptionId: subId, territoryId: tid, limit: 800)
                        return (tid, points)
                    } catch {
                        return (tid, [])
                    }
                }
            }
            for await (tid, points) in group {
                result[tid] = points
            }
        }
        pricePointsByTerritory = result
        isLoadingCustomTiers = false
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
        } catch {
            errorMessage = error.localizedDescription
        }
        isApplying = false
        applyProgress = 0
    }
}
