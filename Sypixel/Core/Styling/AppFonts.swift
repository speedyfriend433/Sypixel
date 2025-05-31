//
//  AppFonts.swift
//  Sypixel
//
//  Created by 이지안 on 5/31/25.
//

import SwiftUI

struct MinecraftTextStyle: ViewModifier {
    let size: CGFloat
    static let fontName = "Minecraft Regular"

    func body(content: Content) -> some View {
        content.font(.custom(MinecraftTextStyle.fontName, size: size))
    }
}

extension View {
    @ViewBuilder
    func minecraftFont(size: CGFloat = 16) -> some View {
        if UIFont(name: MinecraftTextStyle.fontName, size: size) != nil {
            self.modifier(MinecraftTextStyle(size: size))
        } else {
            // print("Warning: Minecraft font '\(MinecraftTextStyle.fontName)' not found. Falling back to system font.")
            self.font(.system(size: size, design: .monospaced))
        }
    }
}
