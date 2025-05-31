//
//  RecentGames.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import Foundation

struct HypixelRecentGamesResponse: Codable {
    let success: Bool
    let games: [RecentGame]?
    let uuid: String?
    let cause: String?
}

struct RecentGame: Codable, Identifiable {
    var id: TimeInterval { date }

    let date: TimeInterval
    let gameType: String?
    let mode: String?
    let map: String?
    let ended: TimeInterval?
    // let kills: Int?
    // let deaths: Int?
    // let win: Bool? 
}
