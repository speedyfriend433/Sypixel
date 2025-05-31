//
//  PlayerResponse.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import Foundation

struct HypixelPlayerAPIResponse: Codable {
    let success: Bool
    let player: Player? 
    let cause: String?
}
