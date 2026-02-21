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
    @State private var cacheClearedId = UUID()

    var body: some View {
        Group {
            if authState.isAuthenticated {
                NavigationSplitView {
                    AppsListView(
                        authState: authState,
                        cacheClearedId: cacheClearedId,
                        selectedApp: $selectedApp
                    )
                    .onChange(of: selectedApp?.id) { _, _ in
                        selectedSubscription = nil
                    }
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
                    .overlay(alignment: .bottom) {
                        if authState.isDemoMode {
                            Text(Loc.ContentView.demoModeBanner)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                        }
                    }
                } content: {
                    SubscriptionsDetailView(
                        authState: authState,
                        app: selectedApp,
                        cacheClearedId: cacheClearedId,
                        selectedSubscription: $selectedSubscription
                    )
                    .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 350)
                } detail: {
                    PriceSettingsView(
                        authState: authState,
                        subscription: selectedSubscription,
                        cacheClearedId: cacheClearedId
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            authState.api?.clearAllCaches()
                            AppIconService.clearCache()
                            cacheClearedId = UUID()
                        } label: {
                            Image(systemName: "arrow.clockwise.circle")
                        }
                        .help(Loc.ContentView.clearCacheTooltip)
                    }
                    ToolbarItem(placement: .automatic) {
                        Button {
                            openWindow(id: AboutView.windowId)
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .help(Loc.ContentView.aboutTooltip)
                    }
                    ToolbarItem(placement: .automatic) {
                        Button(authState.isDemoMode ? Loc.ContentView.exitDemo : Loc.ContentView.logOut) {
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
