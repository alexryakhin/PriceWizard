//
//  PriceSettingsView.swift
//  PriceWizard
//
//  Price configuration UI: base price, preview table, apply to App Store Connect.
//

import SwiftUI

// MARK: - Price Picker Sheet

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
                    ForEach(pricePoints.sorted { priceValue($0.customerPrice) < priceValue($1.customerPrice) }) { opt in
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
    var cacheClearedId: UUID
    @State private var model: PriceSettingsState

    init(authState: AuthState, subscription: SubscriptionResource?, cacheClearedId: UUID) {
        self.authState = authState
        self.subscription = subscription
        self.cacheClearedId = cacheClearedId
        _model = State(initialValue: PriceSettingsState(authState: authState))
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
                        if model.isLoading {
                            HStack {
                                ProgressView()
                                Text(Loc.PriceSettings.loadingPricePoints)
                                    .foregroundStyle(.secondary)
                            }
                        } else if model.usPricePoints.isEmpty {
                            Text(Loc.PriceSettings.noPricePointsForSubscription)
                                .foregroundStyle(.secondary)
                        } else {
                            Picker(Loc.PriceSettings.price, selection: Binding(get: { model.selectedBasePricePoint }, set: { model.selectedBasePricePoint = $0 })) {
                                Text(Loc.PriceSettings.select).tag(nil as SubscriptionPricePointResource?)
                                ForEach(model.usPricePoints.sorted { priceValue($0.attributes.customerPrice ?? "") < priceValue($1.attributes.customerPrice ?? "") }, id: \.id) { pp in
                                    Text(pp.attributes.customerPrice ?? Loc.Subscriptions.unknown).tag(pp as SubscriptionPricePointResource?)
                                }
                            }
                            .onChange(of: model.selectedBasePricePoint) { _, new in
                                if let id = new?.id {
                                    Task { await model.loadEqualizations(pricePointId: id) }
                                } else {
                                    model.equalizations = []
                                    model.territoryMap = [:]
                                    model.pricePointsByTerritory = [:]
                                    model.selectedPricePointByTerritory = [:]
                                }
                            }
                        }
                    }

                    Section(Loc.PriceSettings.indexMode) {
                        Picker(Loc.PriceSettings.mode, selection: Binding(get: { model.indexMode }, set: { model.indexMode = $0 })) {
                            ForEach(PriceSettingsState.IndexMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .onChange(of: model.indexMode) { _, new in
                            switch new {
                            case .netflix:
                                model.territoryIndices = TerritoryIndices.indices(for: .netflix)
                            case .spotify:
                                model.territoryIndices = TerritoryIndices.indices(for: .spotify)
                            case .appleEqualization:
                                break
                            }
                            if !model.territoryMap.isEmpty {
                                Task { await model.resetAndReapplyPrices() }
                            }
                        }
                    }

                    if !model.equalizations.isEmpty {
                        Section(Loc.PriceSettings.preview) {
                            if model.isLoadingCustomTiers {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        ProgressView(value: model.tierLoadProgress, total: 1)
                                            .frame(maxWidth: 200)
                                        if model.tierLoadTotal > 0 {
                                            Text(Loc.PriceSettings.tierProgress(String(model.tierLoadCurrent), String(model.tierLoadTotal)))
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
                            Table(model.previewRows) {
                                TableColumn(Loc.PriceSettings.territory) { row in
                                    if let territory = Territory(apiCode: row.territoryIdForAPI) {
                                        HStack(spacing: 6) {
                                            territory.image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                                .frame(width: 24, height: 24)
                                            Text(territory.localizedDisplayName)
                                        }
                                    } else {
                                        Text(row.territoryDisplay)
                                    }
                                }
                                .width(min: 180, ideal: 200, max: 250)
                                TableColumn(Loc.PriceSettings.currency) { row in
                                    Text(row.currency)
                                }
                                .width(55)
                                TableColumn(Loc.PriceSettings.currentPrice) { row in
                                    Text(row.currentPrice)
                                }
                                TableColumn(Loc.PriceSettings.newPrice) { row in
                                    Button {
                                        model.territoryIdForPriceSheet = row.territoryIdForAPI
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
                        Toggle(Loc.PriceSettings.preserveCurrentPrice, isOn: Binding(get: { model.preserveCurrentPriceForExisting }, set: { model.preserveCurrentPriceForExisting = $0 }))
                        DatePicker(Loc.PriceSettings.startDate, selection: Binding(get: { model.priceStartDate }, set: { model.priceStartDate = $0 }), displayedComponents: .date)
                        if let next = model.nextScheduledStartDate {
                            let formatted = next.formatted(date: .abbreviated, time: .omitted)
                            Text(Loc.PriceSettings.nextScheduledChange(formatted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if !model.existingPrices.isEmpty {
                            Text(Loc.PriceSettings.noFutureScheduledChanges)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if model.isStartDateConflictingWithScheduled {
                            Label(Loc.PriceSettings.startDateConflict, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }

                    Section {
                        if authState.isDemoMode {
                            Text(Loc.PriceSettings.demoModeApplySimulated)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Button(Loc.PriceSettings.applyToAppStoreConnect) {
                            Task { await model.applyPrices() }
                        }
                        .disabled(!model.canApply)
                        if model.isApplying {
                            ProgressView(value: model.applyProgress)
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .navigationTitle(subscription?.attributes.name ?? "Price Settings")
        .task(id: "\(subscription?.id ?? "").\(cacheClearedId.uuidString)") {
            model.subscription = subscription
            await model.loadData()
        }
        .alert(Loc.PriceSettings.error, isPresented: .constant(model.errorMessage != nil)) {
            Button(Loc.PriceSettings.ok) { model.errorMessage = nil }
        } message: {
            if let err = model.errorMessage {
                Text(err)
            }
        }
        .overlay {
            if let success = model.successMessage {
                Text(success)
                    .padding()
                    .background(.green.opacity(0.9))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .task(id: model.successMessage) {
            guard model.successMessage != nil else { return }
            try? await Task.sleep(for: .seconds(3))
            model.successMessage = nil
        }
        .sheet(item: Binding(
            get: { model.territoryIdForPriceSheet.map { PriceSheetItem(territoryId: $0) } },
            set: { model.territoryIdForPriceSheet = $0?.territoryId }
        )) { item in
            PricePickerSheet(
                territoryDisplay: Territory(apiCode: item.territoryId)?.localizedDisplayName ?? TerritoryNames.displayName(for: item.territoryId),
                currency: model.territoryMap[item.territoryId]?.currency ?? "—",
                selection: Binding(
                    get: { model.selectedPricePointByTerritory[item.territoryId] ?? "" },
                    set: { new in
                        var d = model.selectedPricePointByTerritory
                        d[item.territoryId] = new
                        model.selectedPricePointByTerritory = d
                    }
                ),
                pricePoints: model.pricePointsByTerritory[item.territoryId] ?? [],
                loadPricePoints: { await model.loadPricePointsForTerritory(item.territoryId) },
                isLoading: model.isLoadingPriceSheet,
                onDismiss: { model.territoryIdForPriceSheet = nil }
            )
        }
    }

    private struct PriceSheetItem: Identifiable {
        let territoryId: String
        var id: String { territoryId }
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
}
