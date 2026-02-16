//
//  JWTService.swift
//  PriceWizard
//
//  Generates JWT tokens for App Store Connect API authentication.
//  Uses ES256 signing with .p8 private key.
//

import CryptoKit
import Foundation

enum JWTError: Error {
    case invalidP8Key
    case signingFailed
}

struct JWTService {
    private let keyId: String
    private let issuerId: String
    private let privateKey: P256.Signing.PrivateKey

    init(keyId: String, issuerId: String, p8Content: String) throws {
        self.keyId = keyId
        self.issuerId = issuerId
        self.privateKey = try Self.parseP8(p8Content)
    }

    private static func parseP8(_ content: String) throws -> P256.Signing.PrivateKey {
        try P256.Signing.PrivateKey(pemRepresentation: content)
    }

    /// Generates a JWT valid for 20 minutes (max Apple allows).
    func generateToken() throws -> String {
        let now = Date()
        let exp = now.addingTimeInterval(20 * 60)
        let header: [String: Any] = [
            "alg": "ES256",
            "kid": keyId
        ]
        let payload: [String: Any] = [
            "iss": issuerId,
            "iat": Int(now.timeIntervalSince1970),
            "exp": Int(exp.timeIntervalSince1970),
            "aud": "appstoreconnect-v1"
        ]
        let headerBase64 = base64URLEncode(json: header)
        let payloadBase64 = base64URLEncode(json: payload)
        let message = "\(headerBase64).\(payloadBase64)"
        guard let messageData = message.data(using: .utf8) else {
            throw JWTError.signingFailed
        }
        let signature = try privateKey.signature(for: messageData)
        let signatureBase64 = base64URLEncode(data: signature.rawRepresentation)
        return "\(message).\(signatureBase64)"
    }

    private func base64URLEncode(json: [String: Any]) -> String {
        let data = try! JSONSerialization.data(withJSONObject: json)
        return base64URLEncode(data: data)
    }

    private func base64URLEncode(data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
