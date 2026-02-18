//
//  SubscriptionsDetailView.swift
//  PriceWizard
//
//  Detail view listing subscriptions for the selected app.
//

import SwiftUI

struct SubscriptionsDetailView: View {
    @Bindable var authState: AuthState
    let app: AppResource?
    @Binding var selectedSubscription: SubscriptionResource?
    @State private var subscriptions: [SubscriptionResource] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if app == nil {
                ContentUnavailableView(
                    "Select an App",
                    systemImage: "app.badge",
                    description: Text("Choose an app from the sidebar to see its subscriptions.")
                )
            } else if isLoading {
                ProgressView("Loading subscriptions…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else if subscriptions.isEmpty {
                ContentUnavailableView(
                    "No Subscriptions",
                    systemImage: "creditcard",
                    description: Text("This app has no in-app subscriptions.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(subscriptions, id: \.id) { sub in
                            SubscriptionRow(subscription: sub, isSelected: selectedSubscription?.id == sub.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSubscription = sub
                                }
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .navigationTitle(app?.attributes.name ?? "Subscriptions")
        .task(id: app?.id) {
            await loadSubscriptions()
        }
        .refreshable {
            await loadSubscriptions()
        }
    }

    private func loadSubscriptions() async {
        guard let api = authState.api, let appId = app?.id else {
            subscriptions = []
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let groups = try await api.getSubscriptionGroups(appId: appId)
            var all: [SubscriptionResource] = []
            for group in groups {
                let subs = try await api.getSubscriptions(groupId: group.id)
                all.append(contentsOf: subs)
            }
            subscriptions = all
        } catch {
            errorMessage = error.localizedDescription
            subscriptions = []
        }
        isLoading = false
    }
}

struct SubscriptionRow: View {
    let subscription: SubscriptionResource
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "creditcard.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.attributes.name ?? subscription.attributes.productId ?? "Unknown")
                    .font(.headline)
                if let productId = subscription.attributes.productId {
                    Text(productId)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 8)
            if let period = subscription.attributes.subscriptionPeriod {
                Text(periodDisplay(period))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
    }

    private func periodDisplay(_ period: String) -> String {
        switch period {
        case "ONE_WEEK": return "Weekly"
        case "ONE_MONTH": return "Monthly"
        case "TWO_MONTHS": return "2 months"
        case "THREE_MONTHS": return "3 months"
        case "SIX_MONTHS": return "6 months"
        case "ONE_YEAR": return "Yearly"
        default: return period
        }
    }
}
