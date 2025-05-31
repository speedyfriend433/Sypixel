//
//  SettingsView.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = APIKeyManager.shared.getAPIKey() ?? ""
    @State private var message: String?
    @State private var messageColor: Color = .sypixelGreenOnline

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sypixelDarkGray.ignoresSafeArea()

                Form {
                    Section {
                        TextField("Enter your API Key", text: $apiKey)
                            .minecraftFont(size: 16)
                            .padding(8)
                            .background(Color.sypixelLightGray.opacity(0.15))
                            .cornerRadius(4)
                            .foregroundColor(.white)
                            .accentColor(.sypixelGold)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.sypixelLightGray.opacity(0.4), lineWidth: 1)
                            )

                        Button("Save API Key") {
                            saveKey()
                        }
                        .minecraftFont(size: 16)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .background(Color.sypixelPrimaryBlue)
                        .cornerRadius(5)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        
                    } header: {
                        Text("Hypixel API Key")
                            .minecraftFont(size: 18)
                            .foregroundColor(.sypixelGold)
                            .padding(.top, 10)
                    } footer: {
                        Text("Get your API key by typing `/api new` in Hypixel chat.")
                            .minecraftFont(size: 12)
                            .foregroundColor(Color.sypixelLightGray.opacity(0.8))
                    }
                    .listRowBackground(Color.sypixelDarkGray.opacity(0.8))

                    if let msg = message {
                        Section {
                            Text(msg)
                                .minecraftFont(size: 14)
                                .foregroundColor(messageColor)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .listRowBackground(Color.sypixelDarkGray.opacity(0.8))
                    }
                }
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 40)
            }
            .navigationTitle("Sypixel Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.sypixelDarkGray, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func saveKey() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKey.isEmpty {
            APIKeyManager.shared.removeAPIKey()
            message = "API Key removed."
            messageColor = .orange 
        } else {
            if isValidUUID(trimmedKey) {
                APIKeyManager.shared.saveAPIKey(trimmedKey)
                message = "API Key saved successfully!"
                messageColor = .sypixelGreenOnline
            } else {
                message = "Invalid API Key format."
                messageColor = .sypixelRedError
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.message = nil
        }
    }

    private func isValidUUID(_ string: String) -> Bool {
        let uuidPattern = "^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$"
        return NSPredicate(format: "SELF MATCHES %@", uuidPattern).evaluate(with: string)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
