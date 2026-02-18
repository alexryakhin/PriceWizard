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
                } content: {
                    SubscriptionsDetailView(
                        authState: authState,
                        app: selectedApp,
                        selectedSubscription: $selectedSubscription
                    )
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
        .frame(minWidth: 900, minHeight: 600)
    }
}

#Preview {
    ContentView()
}
