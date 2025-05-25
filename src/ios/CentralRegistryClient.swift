//
//  CentralRegistryClient.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 4/12/25.
//

import Foundation
import Combine

// Model for registered games
struct RegisteredGame: Identifiable, Codable {
  var id = UUID()
  let game_id: String
  let host_name: String
  let ip_address: String
  let port: Int
  let metadata: [String: String]
  var last_seen: TimeInterval
  
  enum CodingKeys: String, CodingKey {
    case game_id, host_name, ip_address, port, metadata, last_seen
  }
}


@objcMembers class CentralRegistryClient: NSObject, ObservableObject {
  static let shared = CentralRegistryClient()
  
  // The base URL to your VPS service
  //  private let baseURL = "http://172.245.148.105:8100"
  private let baseURL = "http://10.0.0.1:8100"
  
  // Published properties for UI updates
  @Published var availableGames: [RegisteredGame] = []
  @Published var isHosting = false
  @Published var isVPNConnected: Bool = false
  
  // Client specific data
  private var gameID: String?
  private var heartbeatTimer: Timer?
  
  var launcherVM: LauncherViewModel?
  var serviceName = UIDevice.current.name
  
  private override init() {
    super.init()
  }
  
  func checkVPNStatus() -> Bool {
    var isConnected = false
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return false }
    defer { freeifaddrs(ifaddr) }
    
    var ptr = ifaddr
    while ptr != nil {
      defer { ptr = ptr?.pointee.ifa_next }
      
      let interface = ptr?.pointee
      let addrFamily = interface?.ifa_addr.pointee.sa_family
      
      if addrFamily == UInt8(AF_INET) {
        let name = String(cString: (interface?.ifa_name)!)
        
        if name.contains("utun") || name.contains("tun") {
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                      &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
          
          let address = String(cString: hostname)
          if address.hasPrefix("10.0.0.") {
            isConnected = true
            break
          }
        }
      }
    }
    
    // Update published property if changed
    if isConnected != isVPNConnected {
      DispatchQueue.main.async {
        self.isVPNConnected = isConnected
      }
    }
    
    return isConnected
  }
  
  
  // Register this device as a game host
  func registerGame(hostName: String, port: Int, metadata: [String: String]) {
    print("Registry: Registering game with metadata: \(metadata)")
    isHosting = true
    gameID = UUID().uuidString
    
    guard let gameID = gameID else { return }
    
    // Get device's WireGuard IP address
    let ipAddress = getDeviceWireGuardIP() ?? "unknown"
    print("Registry: Device WireGuard IP: \(ipAddress)")
    
    let registerData: [String: Any] = [
      "game_id": gameID,
      "host_name": hostName,
      "ip_address": ipAddress,
      "port": port,
      "metadata": metadata
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: registerData) else {
      print("Registry: Failed to serialize registration data")
      return
    }
    
    var request = URLRequest(url: URL(string: "\(baseURL)/register")!)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Registry: Registration error: \(error)")
        return
      }
      
      print("Registry: Game registered successfully with ID: \(gameID)")
      
      // Start sending heartbeats
      self.startHeartbeat()
    }.resume()
  }
  
  // Unregister the game when done hosting
  func unregisterGame() {
    guard let gameID = gameID else { return }
    print("Registry: Unregistering game with ID: \(gameID)")
    
    let unregisterData: [String: Any] = [
      "game_id": gameID
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: unregisterData) else {
      print("Registry: Failed to serialize unregistration data")
      return
    }
    
    var request = URLRequest(url: URL(string: "\(baseURL)/unregister")!)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Registry: Unregistration error: \(error)")
        return
      }
      
      print("Registry: Game unregistered successfully")
      
      // Stop heartbeat
      self.stopHeartbeat()
      self.isHosting = false
      self.gameID = nil
    }.resume()
  }
  
  // Discover available games
  func discoverGames() {
    print("Registry: Discovering games...")
    
    if !checkVPNStatus() {
        print("Registry: Not connected to VPN, skipping discovery")
        DispatchQueue.main.async {
            self.availableGames = []
        }
        return
    }
    
    let request = URLRequest(url: URL(string: "\(baseURL)/discover")!)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Registry: Discovery error: \(error)")
        return
      }
      
      guard let data = data else {
        print("Registry: No data returned from discovery")
        return
      }
      
      do {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let gamesArray = json?["games"] as? [[String: Any]] {
          let decoder = JSONDecoder()
          let gamesData = try JSONSerialization.data(withJSONObject: gamesArray)
          let games = try decoder.decode([RegisteredGame].self, from: gamesData)
          
          DispatchQueue.main.async {
            print("Registry: Discovered \(games.count) games")
            print("Games: \(games)")
            self.availableGames = games
          }
        }
      } catch {
        print("Registry: JSON parsing error: \(error)")
      }
    }.resume()
  }
  
  // Start sending heartbeats to keep the game registration alive
  private func startHeartbeat() {
    print("Registry: Starting heartbeat timer")
    //    stopHeartbeat() // Stop any existing heartbeat
    //
    //    heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
    //      print("Registry: Timer fired! Timer is valid: \(timer.isValid)")
    //      self?.sendHeartbeat()
    //    }
    //
    //    // Fire immediately
    //    heartbeatTimer?.fire()
    
    stopHeartbeat() // Stop any existing heartbeat
    
    let timer = Timer(timeInterval: 15.0, repeats: true) { [weak self] _ in
      self?.sendHeartbeat()
    }
    RunLoop.main.add(timer, forMode: .common)
    heartbeatTimer = timer
    
    // Fire immediately
    sendHeartbeat()
  }
  
  // Stop sending heartbeats
  private func stopHeartbeat() {
    if heartbeatTimer?.isValid == true {
      print("Registry: Stopping valid heartbeat timer")
    } else if heartbeatTimer != nil {
      print("Registry: Stopping invalid heartbeat timer")
    }
    heartbeatTimer?.invalidate()
    heartbeatTimer = nil
  }
  
  // Send a heartbeat to the server
  private func sendHeartbeat() {
    guard let gameID = gameID else { return }
    
    print("Registry: Sending heartbeat for \(gameID)")
    
    let heartbeatData: [String: Any] = [
      "game_id": gameID
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: heartbeatData) else {
      print("Registry: Failed to serialize heartbeat data")
      return
    }
    
    var request = URLRequest(url: URL(string: "\(baseURL)/heartbeat")!)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Registry: Heartbeat error: \(error)")
        return
      }
      
      // Heartbeat successful
      print("Registry: Heartbeat successful for \(gameID)")
    }.resume()
  }
  
  // Helper method to get the device's WireGuard IP
  private func getDeviceWireGuardIP() -> String? {
    // Basic implementation - returns the first IP that looks like a WireGuard IP
    // For a production app, you'd want to be more specific about identifying the WireGuard interface
    
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    defer { freeifaddrs(ifaddr) }
    
    var ptr = ifaddr
    while ptr != nil {
      defer { ptr = ptr?.pointee.ifa_next }
      
      let interface = ptr?.pointee
      let addrFamily = interface?.ifa_addr.pointee.sa_family
      
      if addrFamily == UInt8(AF_INET) {
        let name = String(cString: (interface?.ifa_name)!)
        
        // Look for utun or tun interfaces which are typically VPN interfaces
        if name.contains("utun") || name.contains("tun") {
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                      &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
          
          let address = String(cString: hostname)
          if address.hasPrefix("10.0.0.") {
            return address
          }
        }
      }
    }
    
    // Fallback: For testing, you can return a placeholder address
    // In a real app, you'd want to handle this case differently
    return "10.0.0.2"
  }
  
  func startPublishing(port: Int32) {
    print("Registry: Starting to publish game on port \(port)")

    if !checkVPNStatus() {
        print("Registry: Not connected to VPN, cannot publish game")
        return
    }
    
    isHosting = true
    gameID = UUID().uuidString
    
    var metadata: [String: String] = [:]
    
    // Extract metadata the same way as in BonjourServicePublisher
    if let launcherVM, let selectedIWAD = launcherVM.selectedIWAD {
      metadata["iwadFilename"] = selectedIWAD.filename
      metadata["iwad"] = selectedIWAD.displayName
      
      if !launcherVM.selectedExternalFiles.isEmpty {
        let mods = launcherVM.selectedExternalFiles.map { $0.displayName }.joined(separator: ",")
        metadata["mods"] = mods
      }
    }
    
    // Get device's WireGuard IP address
    let ipAddress = getDeviceWireGuardIP() ?? "unknown"
    print("Registry: Device WireGuard IP: \(ipAddress)")
    
    // Only proceed if we have a valid IP and game ID
    guard let gameID = gameID, ipAddress != "unknown" else {
      print("Registry: Failed to publish - missing IP or game ID")
      return
    }
    
    let registerData: [String: Any] = [
      "game_id": gameID,
      "host_name": serviceName,
      "ip_address": ipAddress,
      "port": Int(port),
      "metadata": metadata
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: registerData) else {
      print("Registry: Failed to serialize registration data")
      return
    }
    
    print("Register: about to register with data: \(registerData)")
    
    var request = URLRequest(url: URL(string: "\(baseURL)/register")!)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
      guard let self = self else { return }
      
      if let error = error {
        print("Registry: Registration error: \(error)")
        return
      }
      
      print("Registry: Game registered successfully with ID: \(gameID)")
      
      // Start sending heartbeats
      self.startHeartbeat()
    }.resume()
  }
  
  func stopPublishing() {
    unregisterGame()
  }
}
