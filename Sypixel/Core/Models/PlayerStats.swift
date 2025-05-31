//
//  PlayerStats.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import Foundation

struct PlayerStatsContainer: Codable {
    let Bedwars: BedwarsStats?
    let SkyWars: SkyWarsStats?
    let MurderMystery: MurderMysteryStats?
    let Duels: DuelsStats?

    enum CodingKeys: String, CodingKey {
        case Bedwars
        case SkyWars
        case MurderMystery
        case Duels
    }
}

struct BedwarsStats: Codable {
    let wins_bedwars: Int?
    let losses_bedwars: Int?
    let kills_bedwars: Int?
    let deaths_bedwars: Int?
    let final_kills_bedwars: Int?
    let final_deaths_bedwars: Int?
    let beds_broken_bedwars: Int?
    let beds_lost_bedwars: Int?
    let games_played_bedwars: Int?
    let experience: Int?
    
    var winLossRatio: Double? {
        guard let wins = wins_bedwars, let losses = losses_bedwars, losses > 0 else { return wins_bedwars != nil ? Double(wins_bedwars!) : nil }
        return Double(wins) / Double(losses)
    }

    var killDeathRatio: Double? {
        guard let kills = kills_bedwars, let deaths = deaths_bedwars, deaths > 0 else { return kills_bedwars != nil ? Double(kills_bedwars!) : nil }
        return Double(kills) / Double(deaths)
    }
    
    var finalKillDeathRatio: Double? {
        guard let fkills = final_kills_bedwars, let fdeaths = final_deaths_bedwars, fdeaths > 0 else { return final_kills_bedwars != nil ? Double(final_kills_bedwars!) : nil }
        return Double(fkills) / Double(fdeaths)
    }
}

struct SkyWarsStats: Codable {
    let wins: Int?
    let losses: Int?
    let kills: Int?
    let deaths: Int?
    let games_played_skywars: Int?
    let experience: Int?
    let levelFormatted: String?
    // let wins_solo_normal: Int?
    // let kills_solo_insane: Int?

    var winLossRatio: Double? {
        guard let wins = wins, let losses = losses, losses > 0 else { return wins != nil ? Double(wins!) : nil }
        return Double(wins) / Double(losses)
    }

    var killDeathRatio: Double? {
        guard let kills = kills, let deaths = deaths, deaths > 0 else { return kills != nil ? Double(kills!) : nil }
        return Double(kills) / Double(deaths)
    }
}

struct MurderMysteryStats: Codable {
    let wins: Int?
    let games: Int?
    let kills: Int?
    let deaths: Int?
    // let murders_murder_mystery: Int?
    // let detective_wins_murder_mystery: Int?
}

struct DuelsStats: Codable {
    let wins: Int?
    let losses: Int?
    let kills: Int?
    let deaths: Int?
    let games_played_duels: Int?
    // let classic_duel_wins: Int?
    // let uhc_duel_wins: Int?
}
