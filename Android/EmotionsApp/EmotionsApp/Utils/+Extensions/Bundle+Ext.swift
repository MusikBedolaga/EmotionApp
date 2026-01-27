//
//  Bundle+Ext.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation

extension Bundle {
    var serverBaseURL: URL {
        guard let urlString = object(forInfoDictionaryKey: "SERVER_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("SERVER_URL is missing or invalid in Info.plist")
        }
        return url
    }
}
