//
//  PlayerStatus.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import Foundation

struct HypixelPlayerStatusResponse: Codable {
    let success: Bool
    let session: PlayerSession?
    let uuid: String?
    let cause: String?
}

struct PlayerSession: Codable {
    let online: Bool
    let gameType: String?
    let mode: String?
    let map: String?      
}
