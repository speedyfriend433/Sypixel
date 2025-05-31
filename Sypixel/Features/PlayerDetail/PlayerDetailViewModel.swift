//
//  PlayerDetailViewModel.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import SwiftUI

@MainActor
class PlayerDetailViewModel: ObservableObject {
    @Published var player: Player
    @Published var playerSession: PlayerSession?
    @Published var isLoadingStatus: Bool = false
    @Published var statusErrorMessage: String?
    // @Published var recentGames: [RecentGame]?
    // @Published var isLoadingRecentGames: Bool = false
    // @Published var recentGamesErrorMessage: String?
    
    private let apiService = HypixelAPIService.shared
    
    init(player: Player) {
        self.player = player
        fetchPlayerStatus()
    }
    
    func fetchPlayerStatus() {
        guard !player.uuid.isEmpty else {
            statusErrorMessage = "Player UUID is missing, cannot fetch status."
            return
        }
        
        isLoadingStatus = true
        statusErrorMessage = nil
        // playerSession = nil
        
        Task {
            do {
                let session = try await apiService.fetchPlayerStatus(uuid: player.uuid)
                self.playerSession = session
                if session.online {
                    print("\(player.displayname) is ONLINE. Game: \(session.gameType ?? "Lobby"), Mode: \(session.mode ?? "N/A")")
                } else {
                    print("\(player.displayname) is OFFLINE.")
                }
            } catch let apiError as SypixelAPIError {
                self.statusErrorMessage = "Status: \(apiError.localizedDescription)"
                print("Error fetching status for \(player.displayname): \(apiError.localizedDescription)")
            } catch {
                self.statusErrorMessage = "Status: An unexpected error occurred. \(error.localizedDescription)"
                print("Unexpected error fetching status for \(player.displayname): \(error.localizedDescription)")
            }
            isLoadingStatus = false
        }
    }
}
