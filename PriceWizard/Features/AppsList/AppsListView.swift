//
//  AppsListView.swift
//  PriceWizard
//
//  Sidebar list of apps from App Store Connect.
//

import SwiftUI

struct AppsListView: View {
    @Bindable var authState: AuthState
    var cacheClearedId: UUID
    @Binding var selectedApp: AppResource?
    @State private var apps: [AppResource] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ContentUnavailableView {
                    Label(Loc.AppsList.loading, systemImage: "arrow.triangle.2.circlepath")
                } description: {
                    Text(Loc.AppsList.loadingDescription)
                }
            } else if let error = errorMessage {
                ContentUnavailableView {
                    Label(Loc.AppsList.error, systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(apps, id: \.id) { app in
                            AppRow(app: app, isSelected: selectedApp?.id == app.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedApp = app
                                }
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .navigationTitle(Loc.AppsList.title)
        .task(id: cacheClearedId) {
            await loadApps(ignoreCache: true)
        }
        .refreshable {
            await loadApps(ignoreCache: true)
        }
    }

    private func loadApps(ignoreCache: Bool = false) async {
        guard let api = authState.api else { return }
        isLoading = true
        errorMessage = nil
        do {
            apps = try await api.getApps(ignoreCache: ignoreCache)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct AppRow: View {
    let app: AppResource
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            AppIconView(bundleId: app.attributes.bundleId, size: 28)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(app.attributes.name ?? "Unknown")
                    .font(.headline)
                if let bundleId = app.attributes.bundleId {
                    Text(bundleId)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
    }
}
