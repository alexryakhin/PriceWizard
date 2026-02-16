//
//  KeychainService.swift
//  PriceWizard
//
//  Secure storage for App Store Connect API credentials.
//

import Foundation
import Security

enum KeychainError: Error {
    case encodingFailed
    case decodingFailed
    case secError(OSStatus)
}

struct KeychainService {
    private static let serviceName = "com.pricewizard.appstoreconnect"

    static func saveCredentials(keyId: String, issuerId: String, p8Content: String) throws {
        let credentials = APICredentials(keyId: keyId, issuerId: issuerId, p8Content: p8Content)
        let data = try JSONEncoder().encode(credentials)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: "api-credentials"
        ]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            let update: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(query as CFDictionary, update as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.secError(updateStatus)
            }
        } else if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.secError(addStatus)
            }
        } else {
            throw KeychainError.secError(status)
        }
    }

    static func loadCredentials() throws -> APICredentials {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: "api-credentials",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            if status == errSecItemNotFound {
                throw KeychainError.decodingFailed
            }
            throw KeychainError.secError(status)
        }
        return try JSONDecoder().decode(APICredentials.self, from: data)
    }

    static func deleteCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: "api-credentials"
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.secError(status)
        }
    }
}

struct APICredentials: Codable {
    let keyId: String
    let issuerId: String
    let p8Content: String
}
