//
//  AppIconService.swift
//  PriceWizard
//
//  Fetches app icon URLs from the public iTunes Lookup API (by bundle ID).
//  Apple allows use of App icons from the API to promote store content.
//

import Foundation

enum AppIconService {
    private static let baseURL = "https://itunes.apple.com/lookup"
    private static var cache: [String: URL] = [:]
    private static let cacheLock = NSLock()

    /// Clears the in-memory icon cache. Call with API clearAllCaches when doing a full cache clear.
    static func clearCache() {
        cacheLock.lock()
        cache.removeAll()
        cacheLock.unlock()
    }

    /// Returns a URL for the app icon (60pt) for the given bundle ID, or nil if not found.
    /// Results are cached in memory.
    static func iconURL(bundleId: String) async -> URL? {
        guard !bundleId.isEmpty else { return nil }
        cacheLock.lock()
        if let cached = cache[bundleId] {
            cacheLock.unlock()
            return cached
        }
        cacheLock.unlock()

        guard let encoded = bundleId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?bundleId=\(encoded)&limit=1")
        else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ITunesLookupResponse.self, from: data)
            guard let first = response.results.first,
                  let iconURLString = first.artworkUrl60 ?? first.artworkUrl100 ?? first.artworkUrl512,
                  let iconURL = URL(string: iconURLString)
            else { return nil }
            cacheLock.lock()
            cache[bundleId] = iconURL
            cacheLock.unlock()
            return iconURL
        } catch {
            return nil
        }
    }
}

private struct ITunesLookupResponse: Codable {
    let results: [ITunesLookupResult]
}

private struct ITunesLookupResult: Codable {
    let artworkUrl60: String?
    let artworkUrl100: String?
    let artworkUrl512: String?
}
