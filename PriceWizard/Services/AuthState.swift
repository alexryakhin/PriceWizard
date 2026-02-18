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

    private(set) var api: AppStoreConnectAPI?
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
            errorMessage = nil
        } catch {
            errorMessage = "Invalid API key: \(error.localizedDescription)"
            isAuthenticated = false
            api = nil
            jwtService = nil
        }
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
        try? KeychainService.deleteCredentials()
        AppIconService.clearCache()
        isAuthenticated = false
        api = nil
        jwtService = nil
    }
}
