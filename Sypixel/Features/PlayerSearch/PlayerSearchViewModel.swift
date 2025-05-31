//
//  PlayerSearchViewModel.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import SwiftUI

@MainActor
class PlayerSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchedPlayer: Player?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showPlayerDetail: Bool = false

    private let apiService = HypixelAPIService.shared
    private let apiKeyManager = APIKeyManager.shared

    func searchPlayer() {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else {
            errorMessage = "Please enter a player name or UUID."
            isLoading = false
            return
        }

        guard apiKeyManager.hasAPIKey() else {
            errorMessage = "Hypixel API Key is not set. Please go to Settings to add it."
            isLoading = false
            return
        }

        isLoading = true
        searchedPlayer = nil
        errorMessage = nil
        showPlayerDetail = false

        Task {
            do {
                let player = try await apiService.fetchPlayerData(identifier: trimmedSearchText)
                self.searchedPlayer = player
                self.showPlayerDetail = true
                print("Successfully fetched player: \(player.displayname)")
            } catch let apiError as SypixelAPIError {
                self.errorMessage = apiError.localizedDescription
                print("SypixelAPIError: \(apiError.localizedDescription)")
            } catch {
                self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                print("Unexpected error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}
