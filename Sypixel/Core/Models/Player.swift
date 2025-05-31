//
//  Player.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//


import Foundation

struct Player: Codable, Identifiable {
    var id: String { uuid }

    let uuid: String
    let displayname: String
    let rank: String?
    let packageRank: String?
    let newPackageRank: String?
    let monthlyPackageRank: String?
    let rankPlusColor: String?
    let prefix: String?
    let firstLogin: TimeInterval?
    let lastLogin: TimeInterval?
    let lastLogout: TimeInterval?
    let networkExp: Double?
    let karma: Int?
    let achievementPoints: Int?
    let achievementsOneTime: [String]?
    let socialMedia: SocialMedia?
    let stats: PlayerStatsContainer?

    var SypixelEffectiveRank: String {
        if let prefix = prefix {
            return prefix.replacingOccurrences(of: "§.", with: "", options: .regularExpression)
        }
        if let monthly = monthlyPackageRank, monthly != "NONE", monthly == "SUPERSTAR" {
            return "MVP++"
        }
        if let newRank = newPackageRank, newRank != "NONE" {
            return newRank.replacingOccurrences(of: "_PLUS", with: "+")
                         .replacingOccurrences(of: "SUPERSTAR", with: "MVP++")
                         .replacingOccurrences(of: "VIP_PLUS", with: "VIP+")
                         .replacingOccurrences(of: "MVP_PLUS", with: "MVP+")
        }
        if let pkgRank = packageRank, pkgRank != "NONE" {
             return pkgRank.replacingOccurrences(of: "_PLUS", with: "+")
                          .replacingOccurrences(of: "VIP_PLUS", with: "VIP+")
                          .replacingOccurrences(of: "MVP_PLUS", with: "MVP+")
        }
        if let rawRank = rank, rawRank != "NORMAL" {
            return rawRank
        }
        return "Non-Ranked"
    }
    
    var SypixelRankColorName: String? {
        if monthlyPackageRank == "SUPERSTAR" { return "GOLD" }
        return rankPlusColor
    }

    // Hypixel network level calculation (approximate)
    // Formula from: https://hypixel.net/threads/guide-hypixel-network-level-xp-brackets.1642050/
    // More accurate would be: level = (sqrt((2 * networkExp) + 30625) / 50) - 2.5
    var SypixelNetworkLevel: Double {
        guard let exp = networkExp, exp > 0 else { return 1.0 }

        let base = 10000.0
        let growth = 2500.0
        
        let reversePqPrefix = -(base - 0.5 * growth) / growth
        let reverseConst = reversePqPrefix * reversePqPrefix
        let growthDivides2 = 2.0 / growth
        
        let level = floor(1.0 + reversePqPrefix + sqrt(reverseConst + growthDivides2 * exp))
        return max(1.0, level)
    }
    // enum CodingKeys: String, CodingKey {
    //     case uuid
    //     case displayname
    // }
}

struct SocialMedia: Codable {
    let links: [String: String]?
    // let YOUTUBE: String?
    // let TWITTER: String?
}
