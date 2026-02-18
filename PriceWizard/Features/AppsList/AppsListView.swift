//
//  AppsListView.swift
//  PriceWizard
//
//  Sidebar list of apps from App Store Connect.
//

import SwiftUI

struct AppsListView: View {
    @Bindable var authState: AuthState
    @State private var apps: [AppResource] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var selectedApp: AppResource?

    var body: some View {
        Group {
            if isLoading {
                ContentUnavailableView {
                    Label("Loading", systemImage: "arrow.triangle.2.circlepath")
                } description: {
                    Text("Fetching your apps…")
                }
            } else if let error = errorMessage {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle")
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
        .navigationTitle("Apps")
        .task {
            await loadApps()
        }
        .refreshable {
            await loadApps()
        }
    }

    private func loadApps() async {
        guard let api = authState.api else { return }
        isLoading = true
        errorMessage = nil
        do {
            apps = try await api.getApps()
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
