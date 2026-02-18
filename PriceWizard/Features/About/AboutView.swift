//
//  AboutView.swift
//  PriceWizard
//
//  About app screen: name, version, short description, contact & support.
//

import SwiftUI

private enum Constant {
    static let contactEmail = "bonney977@gmail.com"
    static let buyMeACoffeeURL = "https://buymeacoffee.com/xander1100001"
}

struct AboutView: View {

    static let windowId = "AboutView"

    @Environment(\.dismiss) private var dismiss

    @Environment(\.openURL) private var openURL

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Price Wizard"
    }

    private var version: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(appName)
                    .font(.title.bold())
                Text("Version \(version)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Manage App Store Connect subscription pricing and territories.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
                .padding(.top, 8)

            Text("If Price Wizard saves you time, I’d love to hear from you - or you can buy me a coffee to say thanks.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
                .padding(.top, 8)

            HStack(spacing: 16) {
                Button {
                    if let url = URL(string: "mailto:\(Constant.contactEmail)") {
                        openURL(url)
                    }
                } label: {
                    Label("Email me", systemImage: "envelope.fill")
                }
                .buttonStyle(.bordered)

                Button {
                    if let url = URL(string: Constant.buyMeACoffeeURL) {
                        openURL(url)
                    }
                } label: {
                    Label("Buy me a coffee", systemImage: "cup.and.saucer.fill")
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)

            Spacer(minLength: 24)

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 24)
        }
        .padding(.top, 40)
    }
}

#Preview {
    AboutView()
}
