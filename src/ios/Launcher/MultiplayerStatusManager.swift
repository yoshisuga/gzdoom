//
//  MultiplayerStatusManager.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 5/23/25.
//

import Foundation
import SwiftUI

// MARK: - Data Models
struct MultiplayerStatusResponse: Codable {
  let mpAvailable: Bool
  let mpAvailableZero: Bool
  
  enum CodingKeys: String, CodingKey {
    case mpAvailable = "mp_available"
    case mpAvailableZero = "mp_available_zero"
  }
}

// MARK: - Network Manager
@MainActor
class MultiplayerStatusManager: ObservableObject {
  @Published var status: MultiplayerStatusResponse?
  @Published var isLoading = false
  @Published var error: String?
  
  private let url = URL(string: "https://yoshisuga.github.io/genzd-status.json")!
  
  func fetchStatus() async {
    isLoading = true
    error = nil
    
    do {
      var request = URLRequest(url: url)
      request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
      let (data, _) = try await URLSession.shared.data(for: request)      
      let status = try JSONDecoder().decode(MultiplayerStatusResponse.self, from: data)
      print("response status: \(status)")
      self.status = status
    } catch {
      self.error = "Failed to fetch status: \(error.localizedDescription)"
    }
    
    isLoading = false
  }
}

