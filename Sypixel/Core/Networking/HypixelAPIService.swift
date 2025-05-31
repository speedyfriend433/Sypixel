//
//  HypixelAPIService.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import Foundation

enum SypixelAPIError: Error, LocalizedError {
    case invalidURL(description: String = "The URL for the request was invalid.")
    case apiKeyMissing(description: String = "API Key is not set. Please set it in Settings.")
    case networkError(underlyingError: Error)
    case httpError(statusCode: Int, data: Data?)
    case decodingError(underlyingError: Error)
    case noData(description: String = "No data was received from the server.")
    case playerNotFound(playerName: String)
    case generalAPIError(cause: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let description):
            return description
        case .apiKeyMissing(let description):
            return description
        case .networkError(let underlyingError):
            return "Network error: \(underlyingError.localizedDescription)"
        case .httpError(let statusCode, _):
            if statusCode == 403 { return "Forbidden: Check if your API key has the correct permissions or is valid."}
            if statusCode == 429 { return "Rate limit exceeded. Please try again later."}
            return "Server returned an error: HTTP \(statusCode)."
        case .decodingError(let underlyingError):
            print("Decoding Error Details: \(underlyingError)")
            return "Failed to process data from the server. \(underlyingError.localizedDescription)"
        case .noData(let description):
            return description
        case .playerNotFound(let playerName):
            return "Player '\(playerName)' could not be found."
        case .generalAPIError(let cause):
            return "Hypixel API Error: \(cause)"
        }
    }
}

struct MojangProfile: Codable {
    let id: String
    let name: String
}


@MainActor
class HypixelAPIService {
    static let shared = HypixelAPIService()
    private let mojangBaseURL = "https://api.mojang.com"
    private let hypixelBaseURLV2 = "https://api.hypixel.net/v2"
    
    private let apiKeyManager = APIKeyManager.shared
    private let urlSession: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        self.urlSession = URLSession(configuration: configuration)
    }
    
    // MARK: - Mojang API for UUID
    private func fetchUUID(forUsername username: String) async throws -> String {
        let endpoint = "/users/profiles/minecraft/\(username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username)"
        guard let url = URL(string: mojangBaseURL + endpoint) else {
            throw SypixelAPIError.invalidURL(description: "Could not create Mojang API URL for username: \(username)")
        }
        
        print("Mojang API Request: \(url.absoluteString)")
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SypixelAPIError.networkError(underlyingError: URLError(.badServerResponse))
            }
            
            if httpResponse.statusCode == 204 || httpResponse.statusCode == 404 {
                throw SypixelAPIError.playerNotFound(playerName: username)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw SypixelAPIError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            
            let decoder = JSONDecoder()
            do {
                let mojangProfile = try decoder.decode(MojangProfile.self, from: data)
                return mojangProfile.id
            } catch {
                throw SypixelAPIError.decodingError(underlyingError: error)
            }
        } catch let error as SypixelAPIError {
            throw error
        } catch {
            throw SypixelAPIError.networkError(underlyingError: error)
        }
    }
    
    // MARK: - Hypixel API
    
    func fetchPlayerData(identifier: String) async throws -> Player {
        guard apiKeyManager.hasAPIKey(), let apiKey = apiKeyManager.getAPIKey() else {
            throw SypixelAPIError.apiKeyMissing()
        }
        
        let uuid: String
        let isPotentialUUID = identifier.count == 32 && identifier.allSatisfy { $0.isHexDigit }
        
        if isPotentialUUID {
            print("Identifier '\(identifier)' looks like a UUID.")
            uuid = identifier
        } else if identifier.count >= 3 && identifier.count <= 16 && identifier.range(of: "^[a-zA-Z0-9_]+$", options: .regularExpression) != nil {
            print("Identifier '\(identifier)' looks like a username. Fetching UUID from Mojang...")
            uuid = try await fetchUUID(forUsername: identifier)
        } else {
            print("Identifier '\(identifier)' is not a valid username or UUID format.")
            throw SypixelAPIError.playerNotFound(playerName: identifier)
        }
        
        let endpoint = "/player"
        guard var components = URLComponents(string: hypixelBaseURLV2 + endpoint) else {
            throw SypixelAPIError.invalidURL(description: "Could not create Hypixel Player API URL.")
        }
        
        components.queryItems = [
            URLQueryItem(name: "uuid", value: uuid)
        ]
        
        guard let url = components.url else {
            throw SypixelAPIError.invalidURL(description: "Could not create final Hypixel Player API URL with query items.")
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "API-Key")
        
        print("Hypixel API Request: \(url.absoluteString) with API Key in header")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SypixelAPIError.networkError(underlyingError: URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Hypixel HTTP Error \(httpResponse.statusCode) Body: \(responseBody)")
                }
                throw SypixelAPIError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            // if let jsonString = String(data: data, encoding: .utf8) {
            //     print("Raw JSON Response from Hypixel: \(jsonString)")
            // }
            
            let decoder = JSONDecoder()
            do {
                let apiResponse = try decoder.decode(HypixelPlayerAPIResponse.self, from: data)
                if apiResponse.success, let player = apiResponse.player {
                    return player
                } else if let cause = apiResponse.cause {
                    if cause.lowercased().contains("invalid api key") || cause.lowercased().contains("missing api key") {
                        throw SypixelAPIError.apiKeyMissing(description: "Hypixel API Error: \(cause)")
                    } else if cause.lowercased().contains("player does not exist") || cause.lowercased().contains("not found") {
                        throw SypixelAPIError.playerNotFound(playerName: identifier)
                    }
                    throw SypixelAPIError.generalAPIError(cause: cause)
                } else if apiResponse.player == nil && apiResponse.success {
                    throw SypixelAPIError.playerNotFound(playerName: identifier)
                }
                else {
                    throw SypixelAPIError.generalAPIError(cause: "Unknown error from Hypixel API. Success was false but no cause provided.")
                }
            } catch let decodingError as DecodingError {
                print("--- Detailed Decoding Error ---")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                case .valueNotFound(let value, let context):
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                case .dataCorrupted(let context):
                    print("Data corrupted:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                @unknown default:
                    print("Unknown decoding error: \(decodingError.localizedDescription)")
                }
                print("-------------------------------")
                throw SypixelAPIError.decodingError(underlyingError: decodingError)
            }
            
        } catch let error as SypixelAPIError {
            throw error
        } catch {
            throw SypixelAPIError.networkError(underlyingError: error)
        }
    }
    
    // MARK: - Fetch Player Status
    func fetchPlayerStatus(uuid: String) async throws -> PlayerSession {
        guard apiKeyManager.hasAPIKey(), let apiKey = apiKeyManager.getAPIKey() else {
            throw SypixelAPIError.apiKeyMissing()
        }
        
        let endpoint = "/status" // https://api.hypixel.net/#tag/Player-Data/paths/~1v2~1status/get
        
        guard var components = URLComponents(string: hypixelBaseURLV2 + endpoint) else { // Using hypixelBaseURLV2
            throw SypixelAPIError.invalidURL(description: "Could not create Hypixel Player Status API URL.")
        }
        
        components.queryItems = [
            URLQueryItem(name: "uuid", value: uuid)
        ]
        
        guard let url = components.url else {
            throw SypixelAPIError.invalidURL(description: "Could not create final Hypixel Player Status URL.")
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "API-Key")
        
        print("Hypixel API Request (Status): \(url.absoluteString)")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SypixelAPIError.networkError(underlyingError: URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Hypixel Status HTTP Error \(httpResponse.statusCode) Body: \(responseBody)")
                }
                throw SypixelAPIError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            // if let jsonString = String(data: data, encoding: .utf8) {
            //     print("Raw JSON Response from Status: \(jsonString)")
            // }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let apiResponse = try decoder.decode(HypixelPlayerStatusResponse.self, from: data)
                
                if apiResponse.success, let session = apiResponse.session {
                    return session
                } else if apiResponse.success && apiResponse.session == nil {
                    return PlayerSession(online: false, gameType: nil, mode: nil, map: nil)
                } else if let cause = apiResponse.cause {
                    if cause.lowercased().contains("player does not exist") || cause.lowercased().contains("not found") {
                        throw SypixelAPIError.playerNotFound(playerName: "UUID: \(uuid)")
                    }
                    throw SypixelAPIError.generalAPIError(cause: cause)
                } else {
                    throw SypixelAPIError.generalAPIError(cause: "Unknown error fetching player status. Success was false or session was nil without cause.")
                }
            } catch let decodingError as DecodingError {
                print("--- Detailed Status Decoding Error ---")
                Self.logDecodingError(decodingError)
                print("-------------------------------")
                throw SypixelAPIError.decodingError(underlyingError: decodingError)
            }
        } catch let error as SypixelAPIError {
            throw error
        } catch {
            throw SypixelAPIError.networkError(underlyingError: error)
        }
    }
    
    static func logDecodingError(_ decodingError: DecodingError) {
        switch decodingError {
        case .typeMismatch(let type, let context):
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
        case .valueNotFound(let value, let context):
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
        case .keyNotFound(let key, let context):
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
        case .dataCorrupted(let context):
            print("Data corrupted:", context.debugDescription)
            print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
        @unknown default:
            print("Unknown decoding error: \(decodingError.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Recent Games
    func fetchRecentGames(uuid: String) async throws -> [RecentGame] {
        guard apiKeyManager.hasAPIKey(), let apiKey = apiKeyManager.getAPIKey() else {
            throw SypixelAPIError.apiKeyMissing()
        }
        
        let endpoint = "/recentgames"
        guard var components = URLComponents(string: hypixelBaseURLV2 + endpoint) else {
            throw SypixelAPIError.invalidURL(description: "Could not create Hypixel Recent Games API URL.")
        }
        
        components.queryItems = [
            URLQueryItem(name: "uuid", value: uuid)
        ]
        
        guard let url = components.url else {
            throw SypixelAPIError.invalidURL(description: "Could not create final Hypixel Recent Games URL.")
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "API-Key")
        
        print("Hypixel API Request (Recent Games): \(url.absoluteString)")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SypixelAPIError.networkError(underlyingError: URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Hypixel Recent Games HTTP Error \(httpResponse.statusCode) Body: \(responseBody)")
                }
                throw SypixelAPIError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            
            // if let jsonString = String(data: data, encoding: .utf8) {
            //      print("Raw JSON Response from Recent Games: \(jsonString)")
            // }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let apiResponse = try decoder.decode(HypixelRecentGamesResponse.self, from: data)
                
                if apiResponse.success, let games = apiResponse.games {
                    return games
                } else if apiResponse.success && apiResponse.games == nil {
                    return []
                } else if let cause = apiResponse.cause {
                    if cause.lowercased().contains("player does not exist") || cause.lowercased().contains("not found") {
                        throw SypixelAPIError.playerNotFound(playerName: "UUID: \(uuid)")
                    }
                    throw SypixelAPIError.generalAPIError(cause: cause)
                } else {
                    throw SypixelAPIError.generalAPIError(cause: "Unknown error fetching recent games.")
                }
            } catch let decodingError as DecodingError {
                print("--- Detailed Recent Games Decoding Error ---")
                Self.logDecodingError(decodingError)
                print("---------------------------------------")
                throw SypixelAPIError.decodingError(underlyingError: decodingError)
            }
        } catch let error as SypixelAPIError {
            throw error
        } catch {
            throw SypixelAPIError.networkError(underlyingError: error)
        }
    }
}
