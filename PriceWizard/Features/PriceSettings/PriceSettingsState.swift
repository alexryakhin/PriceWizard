//
//  PriceSettingsState.swift
//  PriceWizard
//
//  Observable state and logic for Price Settings (base price, equalizations, apply).
//

import Foundation
import SwiftUI

/// Territory IDs for United States (Apple may use USA or US)
private let usTerritoryIds = ["USA", "US"]

/// Window of US price points around the base (±20) for equalization – avoids ~800 API calls on load.
private let equalizationWindowHalf = 20

struct PricePointOption: Identifiable {
    let id: String
    let customerPrice: String
}

/// Returns US price points within ±20 of the base, or all if base not found.
func pricePointsForEqualization(
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

/// Parse price string to numeric value for sorting (handles "4.99", "600", "1,99").
func priceValue(_ priceStr: String) -> Double {
    Double(priceStr.replacingOccurrences(of: ",", with: ".")) ?? 0
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

// MARK: - Territory Info

struct TerritoryInfo {
    let id: String
    let currency: String
    let displayName: String
}

// MARK: - Price Settings State

@Observable
final class PriceSettingsState {
    var subscription: SubscriptionResource?
    private let authState: AuthState

    var usPricePoints: [SubscriptionPricePointResource] = []
    var selectedBasePricePoint: SubscriptionPricePointResource?
    var equalizations: [SubscriptionPricePointResource] = []
    var territoryMap: [String: TerritoryInfo] = [:]
    var exchangeRates: [String: Double] = [:]
    var existingPrices: [SubscriptionPriceResource] = []
    var indexMode: IndexMode = .appleEqualization
    var territoryIndices: [String: Double] = [:]
    var pricePointsByTerritory: [String: [PricePointOption]] = [:]
    var selectedPricePointByTerritory: [String: String] = [:]
    var currentPriceByTerritory: [String: String] = [:]
    var isLoading = false
    var isLoadingCustomTiers = false
    var tierLoadProgress: Double = 0
    var tierLoadCurrent: Int = 0
    var tierLoadTotal: Int = 0
    var territoryIdForPriceSheet: String?
    var isLoadingPriceSheet = false
    var isApplying = false
    var preserveCurrentPriceForExisting = false
    var priceStartDate = Date()
    var applyProgress: Double = 0
    var errorMessage: String?
    var successMessage: String?

    enum IndexMode: String, CaseIterable {
        case appleEqualization = "Apple Equalization"
        case netflix = "Netflix"
        case spotify = "Spotify"
    }

    init(authState: AuthState) {
        self.authState = authState
    }

    var usesCustomIndex: Bool {
        switch indexMode {
        case .appleEqualization: return false
        case .netflix, .spotify: return true
        }
    }

    var nextScheduledStartDate: Date? {
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

    var isStartDateConflictingWithScheduled: Bool {
        guard let next = nextScheduledStartDate else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: priceStartDate) == formatter.string(from: next)
    }

    var baseUSD: Double? {
        guard let pp = selectedBasePricePoint, let s = pp.attributes.customerPrice else { return nil }
        return Double(s.replacingOccurrences(of: ",", with: "."))
    }

    struct PreviewRow: Identifiable {
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

    var previewRows: [PreviewRow] {
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

    var canApply: Bool {
        guard selectedBasePricePoint != nil, !isApplying else { return false }
        guard !equalizations.isEmpty else { return false }
        guard !isLoadingCustomTiers else { return false }
        guard !isStartDateConflictingWithScheduled else { return false }
        return previewRows.allSatisfy { !$0.pricePointId.isEmpty }
    }

    func formatUSD(priceStr: String, currency: String) -> String {
        guard let amount = Double(priceStr.replacingOccurrences(of: ",", with: ".")) else { return "—" }
        guard let usd = ExchangeRateService.toUSD(amount: amount, currency: currency, rates: exchangeRates) else {
            return currency == "USD" ? priceStr : "—"
        }
        return String(format: "%.2f", usd)
    }

    func resetContentState() {
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

    func loadData() async {
        resetContentState()
        guard let api = authState.api, let subId = subscription?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            let allPoints = try await api.getSubscriptionPricePoints(subscriptionId: subId, territoryId: "USA", limit: 800)
            let usPoints = allPoints.filter { pp in
                guard let tid = pp.relationships?.territory?.data?.id else { return false }
                return usTerritoryIds.contains(tid)
            }
            let usFiltered99 = usPoints.filter { pp in
                guard let price = pp.attributes.customerPrice else { return false }
                let trimmed = price.trimmingCharacters(in: .whitespaces)
                let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
                let value = Double(normalized)
                let is99 = trimmed.hasSuffix(".99") || trimmed.hasSuffix(",99")
                let is49Under20 = (trimmed.hasSuffix(".49") || trimmed.hasSuffix(",49")) && (value ?? 0) < 20
                return is99 || is49Under20
            }
            usPricePoints = usFiltered99.isEmpty ? usPoints : usFiltered99
            if usPricePoints.isEmpty && !allPoints.isEmpty {
                usPricePoints = allPoints
            }
            let pricesResponse = try await api.getSubscriptionPricesResponse(subscriptionId: subId, limit: 200)
            existingPrices = pricesResponse.data
            currentPriceByTerritory = pricesResponse.currentPriceByTerritory()

            let usCurrentPrice = usTerritoryIds.lazy.compactMap { self.currentPriceByTerritory[$0] }.first
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

    func loadEqualizations(pricePointId: String) async {
        guard let api = authState.api else { return }
        do {
            let (points, territories) = try await api.getPricePointEqualizations(pricePointId: pricePointId, limit: 200)
            guard selectedBasePricePoint?.id == pricePointId else { return }
            equalizations = points
            territoryMap = Dictionary(uniqueKeysWithValues: territories.map { t in
                let name = TerritoryNames.displayName(for: t.id)
                return (t.id, TerritoryInfo(id: t.id, currency: t.attributes.currency ?? "—", displayName: name))
            })
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

    func resetAndReapplyPrices(basePricePointId: String? = nil) async {
        let expectedId = basePricePointId ?? selectedBasePricePoint?.id
        pricePointsByTerritory = [:]
        selectedPricePointByTerritory = [:]

        guard let api = authState.api else { return }
        let territoryIds = Array(territoryMap.keys)
        guard !territoryIds.isEmpty else { return }
        guard selectedBasePricePoint?.id == expectedId else { return }

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

        var pointsByTerritory: [String: [PricePointOption]] = [:]
        for tid in territoryIds {
            pointsByTerritory[tid] = []
        }
        let totalTiers = pointsToEqualize.count
        await withTaskGroup(of: [SubscriptionPricePointResource].self) { group in
            for pp in pointsToEqualize {
                group.addTask {
                    do {
                        let (eqPoints, _) = try await api.getPricePointEqualizations(pricePointId: pp.id, limit: 200)
                        return eqPoints
                    } catch {
                        return []
                    }
                }
            }
            var completed = 0
            for await eqPoints in group {
                guard selectedBasePricePoint?.id == expectedId else { return }
                for eq in eqPoints {
                    guard let tid = eq.relationships?.territory?.data?.id else { continue }
                    let opt = PricePointOption(id: eq.id, customerPrice: eq.attributes.customerPrice ?? "—")
                    if pointsByTerritory[tid]?.contains(where: { $0.id == opt.id }) == false {
                        pointsByTerritory[tid, default: []].append(opt)
                    }
                }
                completed += 1
                tierLoadCurrent = completed
                tierLoadProgress = Double(completed) / Double(totalTiers)
                if completed % 10 == 0 || completed == 1 {
                    debugPrint("[PriceWizard] Loading price tiers \(completed)/\(totalTiers)")
                }
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

    func loadFullTiersForAppleEqualization(basePricePointId: String) async {
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
        let totalTiers = pointsToEqualize.count
        await withTaskGroup(of: [SubscriptionPricePointResource].self) { group in
            for pp in pointsToEqualize {
                group.addTask {
                    do {
                        let (eqPoints, _) = try await api.getPricePointEqualizations(pricePointId: pp.id, limit: 200)
                        return eqPoints
                    } catch {
                        return []
                    }
                }
            }
            var completed = 0
            for await eqPoints in group {
                guard selectedBasePricePoint?.id == basePricePointId else { return }
                for eq in eqPoints {
                    guard let tid = eq.relationships?.territory?.data?.id else { continue }
                    let opt = PricePointOption(id: eq.id, customerPrice: eq.attributes.customerPrice ?? "—")
                    if pointsByTerritory[tid]?.contains(where: { $0.id == opt.id }) == false {
                        pointsByTerritory[tid, default: []].append(opt)
                    }
                }
                completed += 1
                tierLoadCurrent = completed
                tierLoadProgress = Double(completed) / Double(totalTiers)
                if completed % 10 == 0 || completed == 1 {
                    debugPrint("[PriceWizard] Loading price tiers \(completed)/\(totalTiers)")
                }
            }
        }
        guard selectedBasePricePoint?.id == basePricePointId else { return }
        pricePointsByTerritory = pointsByTerritory
        debugPrint("[PriceWizard] Finished loading price tiers (\(pointsToEqualize.count) price points)")
    }

    func loadPricePointsForTerritory(_ territoryId: String) async {
        guard pricePointsByTerritory[territoryId]?.isEmpty == true else { return }
        isLoadingPriceSheet = false
    }

    func applyPrices() async {
        guard let api = authState.api, let subId = subscription?.id else { return }
        isApplying = true
        successMessage = nil
        errorMessage = nil
        let rows = previewRows
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let startDateStr = formatter.string(from: priceStartDate)
        let preserve = preserveCurrentPriceForExisting ? true : nil

        let rowsToApply = rows.filter { row in
            let currentStr = currentPriceByTerritory[row.territoryIdForAPI] ?? ""
            let newStr = row.price
            let currentVal = Double(currentStr.replacingOccurrences(of: ",", with: "."))
            let newVal = Double(newStr.replacingOccurrences(of: ",", with: "."))
            let alreadySame = currentVal != nil && newVal != nil && abs((currentVal ?? 0) - (newVal ?? 0)) < 0.001
            return !alreadySame
        }

        do {
            if rowsToApply.isEmpty {
                successMessage = Loc.PriceSettings.appliedPricesWithSkipped(0, rows.count)
                for row in rows {
                    currentPriceByTerritory[row.territoryIdForAPI] = row.price
                }
            } else {
                let totalToApply = Double(rowsToApply.count)
                var completed = 0
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for row in rowsToApply {
                        group.addTask {
                            try await api.createSubscriptionPrice(
                                subscriptionId: subId,
                                pricePointId: row.pricePointId,
                                territoryId: row.territoryIdForAPI,
                                startDate: startDateStr,
                                preserveCurrentPrice: preserve
                            )
                        }
                    }
                    for try await _ in group {
                        completed += 1
                        applyProgress = Double(completed) / totalToApply
                    }
                }
                let appliedCount = rowsToApply.count
                let skipped = rows.count - appliedCount
                if skipped > 0 {
                    successMessage = Loc.PriceSettings.appliedPricesWithSkipped(appliedCount, skipped)
                } else {
                    successMessage = Loc.PriceSettings.appliedPricesSuccess(rows.count)
                }
                for row in rows {
                    currentPriceByTerritory[row.territoryIdForAPI] = row.price
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isApplying = false
        applyProgress = 0
    }
}
