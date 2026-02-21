//
//  Bundle+Extension.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 3/8/25.
//

import Foundation

enum BundleError: LocalizedError {
    case fileNotFound
    case failedToRead
    case failedToDecode

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Failed to locate file in bundle."
        case .failedToRead:
            return "Failed to read file from bundle."
        case .failedToDecode:
            return "Failed to decode file from bundle"
        }
    }
}

extension Bundle {
    // Use generic T type here to decode anything from almost any JSON Data file.
    func decode<T: Decodable>(_ file: String) throws -> T {
        // Getting the location of the file in our bundle and setting a temporary URL constant.
        guard let url = self.url(forResource: file, withExtension: "json") else {
            debugPrint("Failed to locate \(file) in bundle.")
            throw BundleError.fileNotFound
        }

        // Setting a temporary data constant with Data from the file found in the bundle.
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            debugPrint("Failed to read \(file) from bundle: \(error)")
            throw BundleError.failedToRead
        }

        // Decoder instance.
        let decoder = JSONDecoder()

        // Format date to read easier.
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)

        // Loading data from the data constant.
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            debugPrint("Failed to decode \(file) from bundle: \(error)")
            throw BundleError.failedToDecode
        }
    }

    func string(forResource file: String, withExtension: String? = nil) throws -> String {
        guard let url = self.url(forResource: file, withExtension: withExtension) else {
            debugPrint("Failed to locate \(file) in bundle.")
            throw BundleError.fileNotFound
        }

        return try String(contentsOf: url)
    }
}
