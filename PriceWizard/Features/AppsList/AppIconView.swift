//
//  AppIconView.swift
//  PriceWizard
//
//  Displays an app icon from the iTunes Lookup API or a placeholder.
//

import SwiftUI

struct AppIconView: View {
    let bundleId: String?
    var size: CGFloat = 28
    var cornerRadius: CGFloat = 6

    @State private var iconURL: URL?

    var body: some View {
        Group {
            if let url = iconURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .task(id: bundleId) {
            guard let bundleId else { return }
            iconURL = await AppIconService.iconURL(bundleId: bundleId)
        }
    }

    private var placeholder: some View {
        Image(systemName: "app.badge.fill")
            .font(.system(size: size * 0.6))
            .foregroundStyle(.secondary)
            .frame(width: size, height: size)
    }
}
