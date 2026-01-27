import Foundation
import Security

protocol CredentialsStore {
    func save(username: String, password: String) throws
    func getCredentials() throws -> (username: String, password: String)?
    func clearCredentials() throws
}

protocol TokenStore {
    func save(token: String) throws
    func getToken() throws -> String?
    func clearToken() throws
}

final class KeychainStore {
    enum KeychainStoreError: Error {
        case saveFailed(OSStatus)
        case readFailed(OSStatus)
        case deleteFailed(OSStatus)
        case invalidData
    }

    private let service: String
    private let accessGroup: String?

    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
}

// MARK: - CredentialsStore
extension KeychainStore: CredentialsStore {
    private static let usernameKey = "com.emotions.username"
    private static let passwordKey = "com.emotions.password"

    func save(username: String, password: String) throws {
        guard let usernameData = username.data(using: .utf8),
              let passwordData = password.data(using: .utf8) else {
            throw KeychainStoreError.invalidData
        }
        try save(key: Self.usernameKey, value: usernameData)
        try save(key: Self.passwordKey, value: passwordData)
    }

    func getCredentials() throws -> (username: String, password: String)? {
        guard let usernameData = try read(key: Self.usernameKey),
              let passwordData = try read(key: Self.passwordKey) else {
            return nil
        }
        guard let username = String(data: usernameData, encoding: .utf8),
              let password = String(data: passwordData, encoding: .utf8) else {
            throw KeychainStoreError.invalidData
        }
        return (username, password)
    }

    func clearCredentials() throws {
        try delete(key: Self.usernameKey)
        try delete(key: Self.passwordKey)
    }
}

// MARK: - TokenStore
extension KeychainStore: TokenStore {
    private static let tokenKey = "com.emotions.token"

    func save(token: String) throws {
        guard let tokenData = token.data(using: .utf8) else {
            throw KeychainStoreError.invalidData
        }
        try save(key: Self.tokenKey, value: tokenData)
    }

    func getToken() throws -> String? {
        guard let tokenData = try read(key: Self.tokenKey) else {
            return nil
        }
        guard let token = String(data: tokenData, encoding: .utf8) else {
            throw KeychainStoreError.invalidData
        }
        return token
    }

    func clearToken() throws {
        try delete(key: Self.tokenKey)
    }
}

// MARK: - Helpers
private extension KeychainStore {
    func save(key: String, value: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainStoreError.saveFailed(status)
        }
    }

    func read(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        } else if status != errSecSuccess {
            throw KeychainStoreError.readFailed(status)
        }

        guard let data = item as? Data else {
            return nil
        }
        return data
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainStoreError.deleteFailed(status)
        }
    }
}
