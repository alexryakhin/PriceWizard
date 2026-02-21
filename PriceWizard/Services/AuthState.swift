//
//  AuthState.swift
//  PriceWizard
//
//  Global auth state: credentials, API client, and login status.
//

import Foundation

@Observable
final class AuthState {
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    /// Demo mode uses mock data and does not write to App Store Connect.
    private(set) var isDemoMode: Bool = false

    private(set) var api: (any AppStoreConnectAPIProtocol)?
    private var jwtService: JWTService?

    init() {
        if let creds = try? KeychainService.loadCredentials() {
            configure(with: creds)
        }
    }

    func configure(with credentials: APICredentials) {
        do {
            let jwt = try JWTService(keyId: credentials.keyId, issuerId: credentials.issuerId, p8Content: credentials.p8Content)
            jwtService = jwt
            api = AppStoreConnectAPI { [weak self] in
                guard let jwt = self?.jwtService else { throw APIError.unauthorized }
                return try jwt.generateToken()
            }
            isAuthenticated = true
            isDemoMode = false
            errorMessage = nil
        } catch {
            errorMessage = "Invalid API key: \(error.localizedDescription)"
            isAuthenticated = false
            isDemoMode = false
            api = nil
            jwtService = nil
        }
    }

    /// Enters demo mode with mock API so users can explore the UI without App Store Connect access.
    func configureWithDemo() {
        api = MockAppStoreConnectAPI()
        isAuthenticated = true
        isDemoMode = true
        errorMessage = nil
        jwtService = nil
    }

    func saveAndConfigure(keyId: String, issuerId: String, p8Content: String) {
        do {
            try KeychainService.saveCredentials(keyId: keyId, issuerId: issuerId, p8Content: p8Content)
            configure(with: APICredentials(keyId: keyId, issuerId: issuerId, p8Content: p8Content))
        } catch {
            errorMessage = "Failed to save credentials: \(error.localizedDescription)"
        }
    }

    func logout() {
        if !isDemoMode {
            try? KeychainService.deleteCredentials()
        }
        AppIconService.clearCache()
        isAuthenticated = false
        isDemoMode = false
        api = nil
        jwtService = nil
    }
}
