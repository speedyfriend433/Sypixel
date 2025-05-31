//
//  AppColors.swift
//  Sypixel
//
//  Created by 이지안 on 5/31/25.
//

import SwiftUI

extension Color {
    static let sypixelDarkGray = Color(hex: "#2E2E2E")
    static let sypixelLightGray = Color(hex: "#A0A0A0")
    static let sypixelGold = Color(hex: "#FFAA00")
    static let sypixelPrimaryBlue = Color(hex: "#3876A0")
    static let minecraftStone = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let sypixelRedError = Color(hex: "#FF5555")
    static let sypixelGreenOnline = Color(hex: "#55FF55")
    // static let sypixelBrown = Color(hex: "#8B4513")
    // static let sypixelDarkGray = Color("SypixelDarkGrayAssetName")
    // static let sypixelLightGray = Color("SypixelLightGrayAssetName")
    // static let sypixelGold = Color("SypixelGoldAssetName")
    // static let sypixelPrimaryBlue = Color("SypixelPrimaryBlueAssetName")
    // static let minecraftStone = Color("MinecraftStoneAssetName")
    // static let sypixelRedError = Color("SypixelRedErrorAssetName")
    // static let sypixelGreenOnline = Color("SypixelGreenOnlineAssetName")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 0, 255)
            print("Error: Invalid hex string '\(hex)' for Color init. Defaulting to magenta.")
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
