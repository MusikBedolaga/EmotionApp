//
//  EnvironmentValues+Ext.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import SwiftUI

extension EnvironmentValues {
    var secureStore: SecureStore {
        get { self[SecureStoreKey.self] }
        set { self[SecureStoreKey.self] = newValue }
    }
}

extension EnvironmentValues {
    var authService: any AuthService {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
}
