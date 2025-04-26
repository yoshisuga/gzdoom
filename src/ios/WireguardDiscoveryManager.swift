//
//  WireguardDiscoveryManager.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 4/11/25.
//

import Foundation
import Network
import SystemConfiguration

// Structure to represent a discovered peer
struct DiscoveredPeer: Identifiable {
  let id = UUID()
  let ipAddress: String
  let port: Int
  let name: String
  var metadata: [String: String]
  
  // Custom equality check based on IP and port
  static func ==(lhs: DiscoveredPeer, rhs: DiscoveredPeer) -> Bool {
    return lhs.ipAddress == rhs.ipAddress && lhs.port == rhs.port
  }
}

class WireGuardDiscoveryManager: ObservableObject {
  // Service constants
  private let discoveryPort: UInt16 = 27016 // A port unlikely to be in use
  private let serviceBroadcastInterval: TimeInterval = 1.0
  private let peerExpirationTime: TimeInterval = 5.0
  
  // Published properties for UI updates
  @Published var discoveredPeers: [DiscoveredPeer] = []
  @Published var isScanning = false
  @Published var isHosting = false
  
  // Network-related properties
  private var broadcastTimer: Timer?
  private var cleanupTimer: Timer?
  private var udpListener: NWListener?
  private var lastSeenTimes: [String: Date] = [:]
  
  // User and service info
  private var serviceName: String
  private var hostPort: Int
  private var metadata: [String: String]
  
  private var directScanTimer: Timer?
  private var currentScanOffset = 0
  private var myOwnIPLastOctet: Int = 0
  
  init(serviceName: String = UIDevice.current.name, hostPort: Int = 8080, metadata: [String: String] = [:]) {
    self.serviceName = serviceName
    self.hostPort = hostPort
    self.metadata = metadata
  }
  

  // Add these functions directly in your WireGuardDiscoveryManager class
  private func getNetworkInterfaces() -> [(name: String, address: String)] {
      var interfaces = [(name: String, address: String)]()
      
      var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
      guard getifaddrs(&ifaddr) == 0 else {
          return []
      }
      
      var ptr = ifaddr
      while ptr != nil {
          defer { ptr = ptr?.pointee.ifa_next }
          
          let interface = ptr?.pointee
          let addrFamily = interface?.ifa_addr.pointee.sa_family
          
          if addrFamily == UInt8(AF_INET) {
              let name = String(cString: (interface?.ifa_name)!)
              
              var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
              getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                          &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
              
              let address = String(cString: hostname)
              interfaces.append((name: name, address: address))
          }
      }
      
      freeifaddrs(ifaddr)
      return interfaces
  }

  private func determineOwnIP() {
      // Get all network interfaces
      let networkInterfaces = getNetworkInterfaces()
      
      // Look for the WireGuard interface (10.0.0.x)
      for interface in networkInterfaces {
          let address = interface.address
          if address.hasPrefix("10.0.0.") {
              if let lastPart = address.split(separator: ".").last,
                 let octet = Int(lastPart) {
                  myOwnIPLastOctet = octet
                  print("wireguard: Determined own IP address: 10.0.0.\(myOwnIPLastOctet)")
                  break
              }
          }
      }
  }

  private func startDirectScanning() {
      stopDirectScanning()
      
      print("wireguard: Starting direct subnet scan")
      determineOwnIP()
      
      // Prepare metadata string (same as in broadcasting)
      let metadataString = metadata.map { key, value in "\(key)=\(value)" }.joined(separator: ";")
      let message = "ANNOUNCE|\(serviceName)|\(hostPort)|\(metadataString)"
      guard let messageData = message.data(using: .utf8) else { return }
      
      // Set up a timer to scan IPs in batches
      directScanTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
          guard let self = self else { return }
          
          print("wireguard: Scanning IP range 10.0.0.x (batch starting at \(self.currentScanOffset))")
          
          // Scan 20 IPs at a time to avoid flooding the network
          for i in 1...20 {
              let currentScan = (self.currentScanOffset + i) % 254
              if currentScan > 0 && currentScan < 255 && currentScan != self.myOwnIPLastOctet {
                  let targetIP = "10.0.0.\(currentScan)"
                  self.sendUDPMessage(messageData, to: targetIP, port: self.discoveryPort)
              }
          }
          
          // Update offset for next scan batch
          self.currentScanOffset = (self.currentScanOffset + 20) % 254
      }
      
      // Start immediately
      directScanTimer?.fire()
  }

  // Add this method to stop the direct scanning
  private func stopDirectScanning() {
      directScanTimer?.invalidate()
      directScanTimer = nil
  }
  
  // Start hosting a service that others can discover
  func startHosting(port: Int, metadata: [String: String]? = nil) {
      self.hostPort = port
      if let metadata = metadata {
          self.metadata = metadata
      }
      
      isHosting = true
      
      // Start broadcasting our presence
      startBroadcasting()
      
      // Also start direct scanning if we're not already scanning
      if !isScanning {
          startDirectScanning()
      }
  }

  // Update stopHosting to stop direct scanning if needed
  func stopHosting() {
      isHosting = false
      stopBroadcasting()
      
      // Only stop direct scanning if we're not still scanning for others
      if !isScanning {
          stopDirectScanning()
      }
  }
  
  // Start scanning for other services
  func startScanning() {
      isScanning = true
      print("wireguard: Starting service discovery on port \(discoveryPort)")
      
      // Start the cleanup timer
      cleanupTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
          self?.cleanupExpiredPeers()
      }
      
      // Start direct scanning in addition to listening
      startDirectScanning()
      
      do {
          // Set up UDP listener
          let listener = try NWListener(using: .udp, on: NWEndpoint.Port(integerLiteral: discoveryPort))
          
          listener.stateUpdateHandler = { [weak self] state in
              switch state {
              case .ready:
                  print("wireguard: Listener is ready on port \(self?.discoveryPort ?? 0)")
              case .failed(let error):
                  print("wireguard: Listener failed with error: \(error)")
                  self?.isScanning = false
              default:
                  print("wireguard: Listener state changed: \(state)")
              }
          }
          
          // Handle incoming messages
          listener.newConnectionHandler = { [weak self] connection in
              print("wireguard: New incoming connection from \(connection.endpoint)")
              connection.receiveMessage { content, context, isComplete, error in
                  if let error = error {
                      print("wireguard: Error receiving message: \(error)")
                  } else if let content = content, let self = self {
                      self.handleDiscoveryMessage(content: content, connection: connection)
                  } else {
                      print("wireguard: Received empty message or missing self reference")
                  }
                  connection.cancel()
              }
          }
          
          listener.start(queue: .main)
          udpListener = listener
          
      } catch {
          print("wireguard: Failed to create listener: \(error)")
          isScanning = false
      }
  }
  
  // Stop scanning for services
  func stopScanning() {
    isScanning = false
    udpListener?.cancel()
    udpListener = nil
    cleanupTimer?.invalidate()
    cleanupTimer = nil
  }
  
  
  
  // Process received discovery messages
  private func handleDiscoveryMessage(content: Data, connection: NWConnection) {
    guard let message = String(data: content, encoding: .utf8) else {
      print("wireguard: Received undecodable message")
      return
    }
    
    print("wireguard: Received message: \(message)")
    
    // Parse the discovery message
    let components = message.components(separatedBy: "|")
    guard components.count >= 3 else {
      print("wireguard: Invalid message format, insufficient components")
      return
    }
    
    let messageType = components[0]
    let peerName = components[1]
    let peerPort = Int(components[2]) ?? 0
    
    // Only process announcement messages
    guard messageType == "ANNOUNCE" && peerPort > 0 else {
      print("wireguard: Ignoring non-announce message or invalid port: \(messageType) \(peerPort)")
      return
    }
    
    // Get peer IP address
    var peerIP = "unknown"
    switch connection.endpoint {
    case .hostPort(let host, _):
      peerIP = host.debugDescription
    default:
      peerIP = connection.endpoint.debugDescription
    }
    
    // Clean up the IP address string (remove quotes, etc.)
    peerIP = peerIP.replacingOccurrences(of: "\"", with: "")
    if peerIP.hasPrefix("host(") {
      peerIP = String(peerIP.dropFirst(5).dropLast(1))
    }
    
    print("wireguard: Processing announcement from \(peerName) at \(peerIP):\(peerPort)")
    
    // Extract metadata if available
    var metadata: [String: String] = [:]
    if components.count > 3 {
      let metadataString = components[3]
      let pairs = metadataString.components(separatedBy: ";")
      for pair in pairs {
        let keyValue = pair.components(separatedBy: "=")
        if keyValue.count == 2 {
          metadata[keyValue[0]] = keyValue[1]
        }
      }
    }
    
    // Update or add the peer
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      // Update the last seen time
      self.lastSeenTimes["\(peerIP):\(peerPort)"] = Date()
      
      // Check if this peer is already in our list
      let newPeer = DiscoveredPeer(
        ipAddress: peerIP,
        port: peerPort,
        name: peerName,
        metadata: metadata
      )
      
      if let index = self.discoveredPeers.firstIndex(where: { $0.ipAddress == peerIP && $0.port == peerPort }) {
        // Update the existing peer
        self.discoveredPeers[index] = newPeer
      } else {
        // Add the new peer
        self.discoveredPeers.append(newPeer)
        print("WireGuard Discovery: Found peer \(peerName) at \(peerIP):\(peerPort)")
      }
    }
  }
  
  // Start broadcasting service information
  private func startBroadcasting() {
    stopBroadcasting() // Stop any existing broadcast
    
    print("wireguard: Starting broadcast with metadata: \(metadata)")
    
    // Prepare metadata string
    let metadataString = metadata.map { key, value in "\(key)=\(value)" }.joined(separator: ";")
    
    // Format the broadcast message
    let message = "ANNOUNCE|\(serviceName)|\(hostPort)|\(metadataString)"
    print("wireguard: Broadcast message: \(message)")
    guard let messageData = message.data(using: .utf8) else {
      print("wireguard: Failed to encode broadcast message")
      return
    }
    
    // Set up the broadcast timer
    broadcastTimer = Timer.scheduledTimer(withTimeInterval: serviceBroadcastInterval, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      
      print("wireguard: Broadcasting to subnet 10.0.0.255 and \(self.discoveredPeers.count) known peers")
      
      // Broadcast to the WireGuard subnet (10.0.0.255 is the broadcast address)
      self.sendUDPMessage(messageData, to: "10.0.0.255", port: self.discoveryPort)
      
      // Also try to reach all known peers directly to work around potential broadcast limitations
      for peer in self.discoveredPeers {
        self.sendUDPMessage(messageData, to: peer.ipAddress, port: self.discoveryPort)
      }
    }
    
    // Fire immediately for the first broadcast
    broadcastTimer?.fire()
  }
  
  // Stop broadcasting
  private func stopBroadcasting() {
    broadcastTimer?.invalidate()
    broadcastTimer = nil
  }
  
  // Send a UDP message to a specific host and port
  private func sendUDPMessage(_ data: Data, to host: String, port: UInt16) {
    print("wireguard: Sending UDP message to \(host):\(port)")
    
    let endpoint = NWEndpoint.hostPort(host: .init(host), port: .init(integerLiteral: port))
    let connection = NWConnection(to: endpoint, using: .udp)
    
    connection.stateUpdateHandler = { state in
      switch state {
      case .ready:
        print("wireguard: Connection ready to \(host):\(port)")

        connection.send(content: data, completion: .contentProcessed { error in
          if let error = error {
            print("wireguard: Error sending message to \(host):\(port) - \(error)")
          } else {
            print("wireguard: Successfully sent message to \(host):\(port)")
          }
          connection.cancel()
        })
      case .failed(let error):
        print("wireguard: Connection to \(host):\(port) failed - \(error)")
        connection.cancel()
      case .cancelled:
        print("wireguard: Connection to \(host):\(port) cancelled")
      default:
        print("wireguard: Connection to \(host):\(port) state: \(state)")
        break
      }
    }
    
    connection.start(queue: .global())
  }
  
  // Remove peers that haven't been seen recently
  private func cleanupExpiredPeers() {
    let now = Date()
    var peersToRemove: [String] = []
    
    for (key, lastSeen) in lastSeenTimes {
      if now.timeIntervalSince(lastSeen) > peerExpirationTime {
        peersToRemove.append(key)
      }
    }
    
    for key in peersToRemove {
      lastSeenTimes.removeValue(forKey: key)
      let components = key.components(separatedBy: ":")
      if components.count == 2,
         let ip = components.first,
         let port = Int(components.last ?? "0") {
        
        if let index = discoveredPeers.firstIndex(where: { $0.ipAddress == ip && $0.port == port }) {
          let peerName = discoveredPeers[index].name
          discoveredPeers.remove(at: index)
          print("WireGuard Discovery: Peer \(peerName) at \(ip):\(port) expired")
        }
      }
    }
  }
}


extension WireGuardDiscoveryManager {
    enum System {
        struct NetworkInterface {
            let name: String
            let address: String
        }
        
        static func enumerateNetworkInterfaces() throws -> [NetworkInterface] {
            var interfaces = [NetworkInterface]()
            
            var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
            guard getifaddrs(&ifaddr) == 0 else {
                throw NSError(domain: "NetworkError", code: 1, userInfo: nil)
            }
            
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: (interface?.ifa_name)!)
                    
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                    
                    let address = String(cString: hostname)
                    interfaces.append(NetworkInterface(name: name, address: address))
                }
            }
            
            freeifaddrs(ifaddr)
            return interfaces
        }
    }
}
