//
//  APIKeyManager.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import Foundation

class APIKeyManager {
    static let shared = APIKeyManager()
    private let apiKeyUserDefaultsKey = "HypixelAPIKey_SypixelApp"

    private init() {}

    func saveAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: apiKeyUserDefaultsKey)
        print("API Key saved.")
    }

    func getAPIKey() -> String? {
        let key = UserDefaults.standard.string(forKey: apiKeyUserDefaultsKey)
        // print(key == nil ? "No API Key found." : "API Key loaded.")
        return key
    }

    func removeAPIKey() {
        UserDefaults.standard.removeObject(forKey: apiKeyUserDefaultsKey)
        print("API Key removed.")
    }

    func hasAPIKey() -> Bool {
        return getAPIKey() != nil && !(getAPIKey()?.isEmpty ?? true)
    }
}
