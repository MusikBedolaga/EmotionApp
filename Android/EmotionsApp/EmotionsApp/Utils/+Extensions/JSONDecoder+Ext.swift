//
//  JSONDecoder+Ext.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 21.11.2025.
//

import Foundation

extension JSONDecoder {
    static let backend: JSONDecoder = {
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
}
