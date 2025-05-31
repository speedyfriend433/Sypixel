//
//  PlayerDetailView.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import SwiftUI

struct PlayerDetailView: View {
    @StateObject private var viewModel: PlayerDetailViewModel

    init(player: Player) {
        _viewModel = StateObject(wrappedValue: PlayerDetailViewModel(player: player))
    }

    private func formatLoginDate(timestamp: TimeInterval?) -> String {
        guard let timestamp = timestamp else { return "N/A" }
        let date = Date(timeIntervalSince1970: timestamp / 1000.0)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func colorForRank(_ rankColorName: String?) -> Color {
        guard let colorName = rankColorName?.uppercased() else { return .primary }
        switch colorName {
            case "BLACK": return .black
            case "DARK_BLUE": return .sypixelPrimaryBlue
            case "DARK_GREEN": return .green
            case "DARK_AQUA": return .cyan
            case "DARK_RED": return .sypixelRedError
            case "DARK_PURPLE": return .purple
            case "GOLD": return .sypixelGold
            case "GRAY": return .gray
            case "DARK_GRAY": return Color(white: 0.33)
            case "BLUE": return .sypixelPrimaryBlue
            case "GREEN": return .sypixelGreenOnline
            case "AQUA": return .cyan
            case "RED": return .sypixelRedError
            case "LIGHT_PURPLE": return .purple.opacity(0.7)
            case "YELLOW": return .sypixelGold
            case "WHITE": return .white
            default: return .white
        }
    }

    private func formatGameStatus(_ session: PlayerSession?) -> (text: String, color: Color) {
        guard let session = session else {
            return ("Status N/A", .gray)
        }
        
        if !session.online {
            return ("Offline", .gray)
        }

        var statusParts: [String] = []
        if let gameType = session.gameType {
            statusParts.append(gameType.sypixelSanitizedGameName())
        }
        if let mode = session.mode, mode.lowercased() != "lobby" && !(session.gameType?.lowercased().contains("lobby") ?? false) {
            statusParts.append(mode.sypixelSanitizedGameName())
        }
        
        if statusParts.isEmpty {
            return ("Online - In Lobby", .sypixelGreenOnline)
        }
        
        return ("Online - \(statusParts.joined(separator: " "))", .sypixelGreenOnline)
    }

    private func listRowBg() -> some View {
        Color.minecraftStone.opacity(0.6)
    }

    var body: some View {
        ZStack {
            Color.sypixelDarkGray.ignoresSafeArea()

            List {
                Section {
                    InfoRow(label: "Username", value: viewModel.player.displayname)
                        .minecraftFont(size: 18)
                        .listRowBackground(listRowBg())

                    HStack {
                        Text("Rank")
                            .minecraftFont(size: 16)
                            .foregroundColor(Color.sypixelLightGray)
                        Spacer()
                        Text(viewModel.player.SypixelEffectiveRank)
                            .minecraftFont(size: 16)
                            .fontWeight(.bold)
                            .foregroundColor(colorForRank(viewModel.player.SypixelRankColorName))
                    }
                    .listRowBackground(listRowBg())

                    InfoRow(label: "Level", value: String(format: "%.0f", viewModel.player.SypixelNetworkLevel))
                        .minecraftFont(size: 16)
                        .listRowBackground(listRowBg())
                    
                    HStack {
                        Text("Status")
                             .minecraftFont(size: 16)
                             .foregroundColor(Color.sypixelLightGray)
                        Spacer()
                        if viewModel.isLoadingStatus {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .sypixelGold))
                                .scaleEffect(0.7).frame(width: 20, height: 20, alignment: .trailing)
                        } else if let statusError = viewModel.statusErrorMessage {
                            Text(statusError).minecraftFont(size: 12).foregroundColor(.sypixelRedError)
                                .lineLimit(2).multilineTextAlignment(.trailing)
                        } else {
                            let (statusText, statusColor) = formatGameStatus(viewModel.playerSession)
                            Text(statusText).minecraftFont(size: 14).foregroundColor(statusColor)
                                .lineLimit(2).multilineTextAlignment(.trailing)
                        }
                    }
                    .frame(minHeight: 22)
                    .listRowBackground(listRowBg())
                    
                    InfoRow(label: "Karma", value: viewModel.player.karma.map { "\($0)" } ?? "N/A")
                        .minecraftFont(size: 16).listRowBackground(listRowBg())
                    InfoRow(label: "Achievement Pts", value: viewModel.player.achievementPoints.map { "\($0)" } ?? "N/A")
                        .minecraftFont(size: 16).listRowBackground(listRowBg())
                    InfoRow(label: "First Login", value: formatLoginDate(timestamp: viewModel.player.firstLogin))
                        .minecraftFont(size: 14).listRowBackground(listRowBg())
                    InfoRow(label: "Last Login", value: formatLoginDate(timestamp: viewModel.player.lastLogin))
                        .minecraftFont(size: 14).listRowBackground(listRowBg())
                    InfoRow(label: "Last Logout", value: formatLoginDate(timestamp: viewModel.player.lastLogout))
                        .minecraftFont(size: 14).listRowBackground(listRowBg())

                } header: {
                    Text("General Info")
                        .minecraftFont(size: 20)
                        .foregroundColor(.sypixelGold)
                        .padding(.bottom, 5)
                        .textCase(nil)
                }
                .listRowSeparatorTint(Color.sypixelLightGray.opacity(0.3))
                
                if let socialLinks = viewModel.player.socialMedia?.links, !socialLinks.isEmpty {
                    Section {
                        ForEach(socialLinks.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Group {
                                if let url = URL(string: value.starts(with: "http") ? value : "https://\(value)") {
                                    Link(destination: url) {
                                        InfoRow(label: key.sypixelSanitizedGameName(), value: value, showArrow: true)
                                            .minecraftFont(size: 16)
                                    }
                                } else {
                                    InfoRow(label: key.sypixelSanitizedGameName(), value: value)
                                        .minecraftFont(size: 16)
                                }
                            }
                            .listRowBackground(listRowBg())
                        }
                    } header: {
                        Text("Social Media")
                            .minecraftFont(size: 20).foregroundColor(.sypixelGold).padding(.bottom, 5)
                            .textCase(nil)
                    }
                    .listRowSeparatorTint(Color.sypixelLightGray.opacity(0.3))
                }

                if let bwStats = viewModel.player.stats?.Bedwars {
                    Section {
                        InfoRow(label: "Experience", value: bwStats.experience.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Games Played", value: bwStats.games_played_bedwars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Wins", value: bwStats.wins_bedwars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Losses", value: bwStats.losses_bedwars.map { "\($0)" } ?? "N/A")
                             .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "W/L Ratio", value: bwStats.winLossRatio.map { String(format: "%.2f", $0) } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Kills", value: bwStats.kills_bedwars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Deaths", value: bwStats.deaths_bedwars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "K/D Ratio", value: bwStats.killDeathRatio.map { String(format: "%.2f", $0) } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Final Kills", value: bwStats.final_kills_bedwars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Final Deaths", value: bwStats.final_deaths_bedwars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Final K/D Ratio", value: bwStats.finalKillDeathRatio.map { String(format: "%.2f", $0) } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Beds Broken", value: bwStats.beds_broken_bedwars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Beds Lost", value: bwStats.beds_lost_bedwars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                    } header: {
                        Text("Bed Wars")
                            .minecraftFont(size: 20).foregroundColor(.sypixelGold).padding(.bottom, 5)
                            .textCase(nil)
                    }
                    .listRowSeparatorTint(Color.sypixelLightGray.opacity(0.3))
                }
                
                if let swStats = viewModel.player.stats?.SkyWars {
                    Section {
                        InfoRow(label: "Level", value: swStats.levelFormatted ?? (swStats.experience.map { "\($0)" } ?? "N/A"))
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Games Played", value: swStats.games_played_skywars.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Wins", value: swStats.wins.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Losses", value: swStats.losses.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "W/L Ratio", value: swStats.winLossRatio.map { String(format: "%.2f", $0) } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Kills", value: swStats.kills.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Deaths", value: swStats.deaths.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "K/D Ratio", value: swStats.killDeathRatio.map { String(format: "%.2f", $0) } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                    } header: {
                        Text("SkyWars").minecraftFont(size: 20).foregroundColor(.sypixelGold).padding(.bottom, 5).textCase(nil)
                    }
                    .listRowSeparatorTint(Color.sypixelLightGray.opacity(0.3))
                }
            
                if let mmStats = viewModel.player.stats?.MurderMystery {
                     Section {
                        InfoRow(label: "Games Played", value: mmStats.games.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Wins", value: mmStats.wins.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Kills", value: mmStats.kills.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Deaths", value: mmStats.deaths.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                    } header: {
                        Text("Murder Mystery").minecraftFont(size: 20).foregroundColor(.sypixelGold).padding(.bottom, 5).textCase(nil)
                    }
                    .listRowSeparatorTint(Color.sypixelLightGray.opacity(0.3))
                }

                if let duelsStats = viewModel.player.stats?.Duels {
                    Section {
                        InfoRow(label: "Games Played", value: duelsStats.games_played_duels.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Wins", value: duelsStats.wins.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Losses", value: duelsStats.losses.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Kills", value: duelsStats.kills.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                        InfoRow(label: "Deaths", value: duelsStats.deaths.map { "\($0)" } ?? "N/A")
                            .minecraftFont(size: 16).listRowBackground(listRowBg())
                    } header: {
                        Text("Duels").minecraftFont(size: 20).foregroundColor(.sypixelGold).padding(.bottom, 5).textCase(nil)
                    }
                    .listRowSeparatorTint(Color.sypixelLightGray.opacity(0.3))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 35)
        }
        .navigationTitle(viewModel.player.displayname.sypixelSanitizedGameName())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.sypixelDarkGray, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var showArrow: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(Color.sypixelLightGray.opacity(0.9))
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(showArrow ? Color.sypixelPrimaryBlue : .white)
                .lineLimit(1)
                .truncationMode(.tail)
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.sypixelLightGray.opacity(0.7))
            }
        }
        .padding(.vertical, 5)
    }
}

extension String {
    func sypixelSanitizedGameName() -> String {
        return self
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
            .replacingOccurrences(of: "Tnt", with: "TNT")
            .replacingOccurrences(of: "UhC", with: "UHC")
            .replacingOccurrences(of: "Mvp", with: "MVP")
            .replacingOccurrences(of: "Vip", with: "VIP")
            // .split(separator: " ").map { $0.capitalized }.joined(separator: " ")
    }
}

struct PlayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PlayerDetailView(player: Player.mock)
                .preferredColorScheme(.dark)
        }
    }
}

extension Player {
    static var mock: Player {
        Player(
            uuid: "mockuuid12345",
            displayname: "Steve",
            rank: "MVP_PLUS",
            packageRank: "MVP_PLUS",
            newPackageRank: "MVP_PLUS",
            monthlyPackageRank: "SUPERSTAR",
            rankPlusColor: "GOLD",
            prefix: nil,
            firstLogin: Date().timeIntervalSince1970 * 1000 - (3600 * 24 * 365 * 1000),
            lastLogin: Date().timeIntervalSince1970 * 1000 - (3600 * 1000),
            lastLogout: Date().timeIntervalSince1970 * 1000 - (3600 * 2 * 1000),
            networkExp: 12345678.0, 
            karma: 2500000,
            achievementPoints: 7500,
            achievementsOneTime: ["general_first_join", "skywars_win_solo"],
            socialMedia: SocialMedia(links: [
                "YOUTUBE": "youtube.com/user/Hypixel",
                "TWITTER": "twitter.com/HypixelNetwork",
                "DISCORD": "discord.gg/hypixel"
            ]),
            stats: PlayerStatsContainer(
                Bedwars: BedwarsStats(
                    wins_bedwars: 1500, losses_bedwars: 500,
                    kills_bedwars: 10000, deaths_bedwars: 4000,
                    final_kills_bedwars: 2000, final_deaths_bedwars: 800,
                    beds_broken_bedwars: 3000, beds_lost_bedwars: 700,
                    games_played_bedwars: 2000, experience: 567890
                ),
                SkyWars: SkyWarsStats(
                    wins: 800, losses: 300,
                    kills: 5000, deaths: 2000,
                    games_played_skywars: 1100,
                    experience: 1234567, levelFormatted: "15✫ SkyWars God"
                ),
                MurderMystery: MurderMysteryStats(
                    wins: 200, games: 500, kills: 600, deaths: 150
                ),
                Duels: DuelsStats(
                    wins: 1000, losses: 250, kills: 4000, deaths: 1000, games_played_duels: 1250
                )
            )
        )
    }
}
