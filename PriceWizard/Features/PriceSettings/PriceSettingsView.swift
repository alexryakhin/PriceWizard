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
    @State private var existingPrices: [SubscriptionPriceResource] = []
    @State private var indexMode: IndexMode = .appleEqualization
    @State private var territoryIndices: [String: Double] = [:]
    @State private var isLoading = false
    @State private var isApplying = false
    @State private var applyProgress: Double = 0
    @State private var errorMessage: String?
    @State private var successMessage: String?

    enum IndexMode: String, CaseIterable {
        case appleEqualization = "Apple Equalization"
        case customIndex = "Custom Index"
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
                    }

                    if !equalizations.isEmpty {
                        Section("Preview") {
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
                                if indexMode == .customIndex {
                                    TableColumn("Index") { row in
                                        TextField("Index", value: Binding(
                                            get: { territoryIndices[row.territoryIdForAPI] ?? 1.0 },
                                            set: { territoryIndices[row.territoryIdForAPI] = $0 }
                                        ), format: .number.precision(.fractionLength(2)))
                                        .frame(width: 60)
                                    }
                                }
                            }
                        }
                    }

                    Section {
                        Button("Apply to App Store Connect") {
                            Task { await applyPrices() }
                        }
                        .disabled(selectedBasePricePoint == nil || isApplying || equalizations.isEmpty)
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

    private var previewRows: [PreviewRow] {
        equalizations
            .filter { pp in pp.relationships?.territory?.data?.id != nil }
            .map { pp in
                let tid = pp.relationships!.territory!.data!.id
                let info = territoryMap[tid]
                let territoryName = info?.displayName ?? tid
                let currency = info?.currency ?? "—"
                return PreviewRow(
                    territoryIdForAPI: tid,
                    territoryDisplay: territoryName,
                    currency: currency,
                    price: pp.attributes.customerPrice ?? "—",
                    pricePointId: pp.id
                )
            }
    }

    private struct PreviewRow: Identifiable {
        var id: String { pricePointId }
        let territoryIdForAPI: String
        let territoryDisplay: String
        let currency: String
        let price: String
        let pricePointId: String
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
                let name = Self.territoryDisplayName(for: t.id, currency: t.attributes.currency ?? "")
                return (t.id, TerritoryInfo(id: t.id, currency: t.attributes.currency ?? "—", displayName: name))
            })
        } catch {
            errorMessage = error.localizedDescription
            equalizations = []
            territoryMap = [:]
        }
    }

    private static func territoryDisplayName(for code: String, currency: String) -> String {
        let names: [String: String] = [
            "USA": "United States", "US": "United States",
            "GBR": "United Kingdom", "GB": "United Kingdom",
            "CAN": "Canada", "CA": "Canada",
            "AUS": "Australia", "AU": "Australia",
            "DEU": "Germany", "DE": "Germany",
            "FRA": "France", "FR": "France",
            "JPN": "Japan", "JP": "Japan",
            "CHN": "China", "CN": "China",
            "IND": "India", "IN": "India",
            "BRA": "Brazil", "BR": "Brazil",
            "MEX": "Mexico", "MX": "Mexico",
            "ESP": "Spain", "ES": "Spain",
            "ITA": "Italy", "IT": "Italy",
            "KOR": "South Korea", "KR": "South Korea",
            "RUS": "Russia", "RU": "Russia",
            "CHE": "Switzerland", "CH": "Switzerland",
            "NLD": "Netherlands", "NL": "Netherlands",
            "SWE": "Sweden", "SE": "Sweden",
            "POL": "Poland", "PL": "Poland",
            "TUR": "Turkey", "TR": "Turkey"
        ]
        return names[code] ?? (currency.isEmpty ? code : "\(code) · \(currency)")
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
