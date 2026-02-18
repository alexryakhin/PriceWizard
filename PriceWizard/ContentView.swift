//
//  ContentView.swift
//  PriceWizard
//
//  Main app shell: auth gate and NavigationSplitView for apps, subscriptions, prices.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow

    @State private var authState = AuthState()
    @State private var selectedApp: AppResource?
    @State private var selectedSubscription: SubscriptionResource?

    var body: some View {
        Group {
            if authState.isAuthenticated {
                NavigationSplitView {
                    AppsListView(authState: authState, selectedApp: $selectedApp)
                        .onChange(of: selectedApp?.id) { _, _ in
                            selectedSubscription = nil
                        }
                        .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
                } content: {
                    SubscriptionsDetailView(
                        authState: authState,
                        app: selectedApp,
                        selectedSubscription: $selectedSubscription
                    )
                    .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 350)
                } detail: {
                    PriceSettingsView(authState: authState, subscription: selectedSubscription)
                }
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            openWindow(id: AboutView.windowId)
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .help(Loc.ContentView.aboutTooltip)
                    }
                    ToolbarItem(placement: .automatic) {
                        Button(Loc.ContentView.logOut) {
                            authState.logout()
                        }
                    }
                }
            } else {
                AuthSetupView(authState: authState)
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
    }
}

#Preview {
    ContentView()
}
