//
//  KeychainStore.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import SwiftUI
import KeychainSwift

protocol SecureStore: Sendable {
    func set(_ value: String, for key: String) async
    func get(_ key: String) async -> String?
    func remove(_ key: String) async
}

actor KeychainStore: SecureStore {
    private let keychain = KeychainSwift()
    
    func set(_ value: String, for key: String) async {
        print("🔐 [Keychain] SET key: \(key) (value length: \(value.count))")
        keychain.set(value, forKey: key)
    }
    
    func get(_ key: String) async -> String? {
        let val = keychain.get(key)
        if let val {
            print("🔐 [Keychain] GET key: \(key) → FOUND (length: \(val.count))")
        } else {
            print("🔐 [Keychain] GET key: \(key) → EMPTY")
        }
        return val
    }
    
    func remove(_ key: String) async {
        print("🗑️  [Keychain] REMOVE key: \(key)")
        keychain.delete(key)
    }
}

struct SecureStoreKey: EnvironmentKey {
    static let defaultValue: SecureStore = KeychainStore()
}
