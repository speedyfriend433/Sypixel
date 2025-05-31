//
//  PlayerSearchVie.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import SwiftUI

struct PlayerSearchView: View {
    @StateObject private var viewModel = PlayerSearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sypixelDarkGray.ignoresSafeArea()

                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        TextField("Enter Player Name or UUID", text: $viewModel.searchText)
                            .minecraftFont(size: 16)
                            .padding(10)
                            .background(Color.sypixelLightGray.opacity(0.2))
                            .cornerRadius(5)
                            .foregroundColor(.white)
                            .accentColor(.sypixelGold)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.sypixelLightGray.opacity(0.5), lineWidth: 1)
                            )
                            .submitLabel(.search)
                            .onSubmit {
                                viewModel.searchPlayer()
                            }

                        Button {
                            viewModel.searchPlayer()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.sypixelGold)
                        }
                        .padding(10)
                        .background(Color.sypixelPrimaryBlue)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.sypixelPrimaryBlue.opacity(0.7), lineWidth: 1)
                        )
                        .disabled(viewModel.isLoading)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    }
                    .padding(.horizontal)
                    .padding(.top, 25)

                    if viewModel.isLoading {
                        VStack(spacing: 10) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .sypixelGold))
                                .scaleEffect(1.5)
                            Text("Searching Sypixel...")
                                .minecraftFont(size: 16)
                                .foregroundColor(.sypixelGold)
                        }
                        .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.sypixelRedError)
                            Text(errorMessage)
                                .minecraftFont(size: 14)
                                .foregroundColor(.sypixelRedError)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    }

                    Spacer()
                }
            }
            .navigationTitle("Sypixel Player Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.sypixelDarkGray, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar) 
            .navigationDestination(isPresented: $viewModel.showPlayerDetail) {
                if let player = viewModel.searchedPlayer {
                    PlayerDetailView(player: player)
                } else {
                    Text("Error: Player data not available.")
                        .minecraftFont(size: 16)
                        .foregroundColor(.sypixelRedError)
                }
            }
        }
    }
}

struct PlayerSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSearchView()
            .preferredColorScheme(.dark)
    }
}
