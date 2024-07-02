//
//  Color+Extensions.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 4), (int >> 4) & 0xF, int & 0xF)
            self.init(
                red: Double(r) / 15.0,
                green: Double(g) / 15.0,
                blue: Double(b) / 15.0,
                opacity: Double(a) / 255.0
            )
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16), (int >> 8) & 0xFF, int & 0xFF)
            self.init(
                red: Double(r) / 255.0,
                green: Double(g) / 255.0,
                blue: Double(b) / 255.0,
                opacity: Double(a) / 255.0
            )
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
            self.init(
                red: Double(r) / 255.0,
                green: Double(g) / 255.0,
                blue: Double(b) / 255.0,
                opacity: Double(a) / 255.0
            )
        default:
            self.init(
                red: 1.0,
                green: 1.0,
                blue: 1.0,
                opacity: 1.0
            )
        }
    }
}
