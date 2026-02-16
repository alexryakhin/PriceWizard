//
//  AuthSetupView.swift
//  PriceWizard
//
//  UI for configuring App Store Connect API credentials.
//

import SwiftUI
import UniformTypeIdentifiers

struct AuthSetupView: View {
    @Bindable var authState: AuthState
    @State private var keyId = ""
    @State private var issuerId = ""
    @State private var p8Content = ""
    @State private var p8FileName: String?
    @State private var isImportingP8 = false

    var body: some View {
        VStack(spacing: 24) {
            Text("App Store Connect API")
                .font(.title)

            Text("Enter your API key details from App Store Connect > Users and Access > Integrations.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 12) {
                TextField("Key ID", text: $keyId, prompt: Text("XXXXXXXXXX"))
                    .textFieldStyle(.roundedBorder)

                TextField("Issuer ID", text: $issuerId, prompt: Text("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"))
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button {
                        isImportingP8 = true
                    } label: {
                        Label(
                            p8FileName ?? "Select AuthKey_XXXXXXXX.p8",
                            systemImage: "doc.badge.plus"
                        )
                    }
                    .buttonStyle(.bordered)
                    if p8FileName != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .frame(maxWidth: 300)

            if let error = authState.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Connect") {
                authState.saveAndConfigure(keyId: keyId, issuerId: issuerId, p8Content: p8Content)
            }
            .buttonStyle(.borderedProminent)
            .disabled(keyId.isEmpty || issuerId.isEmpty || p8Content.isEmpty)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 350)
        .fileImporter(
            isPresented: $isImportingP8,
            allowedContentTypes: [UTType.data, UTType.plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first,
                      url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url),
                   let str = String(data: data, encoding: .utf8) {
                    p8Content = str
                    p8FileName = url.lastPathComponent
                }
            case .failure:
                break
            }
        }
    }
}
