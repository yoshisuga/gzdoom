//
//  MultiplayerSheetView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import Combine
import SwiftUI
import SystemConfiguration

struct MultiplayerSheetView: View {
  @Environment(\.dismiss) var dismiss
  
  var viewModel: LauncherViewModel
  
  @State private var isHost = false
  @State private var numPlayers = ""
  @State private var isDeathmatch = false
  @State private var hostname = ""
  @State private var startMap = ""
  @State private var skillLevel = ""
  
  @State private var selectedService: DiscoveredService?
  
  @StateObject private var browser = BonjourServiceBrowser()
  
  @StateObject private var centralRegistry = CentralRegistryClient.shared
  
  @State private var selectedGame: RegisteredGame?
  
  @State private var discoverTimer: Timer?
  @State private var connectionCheckTimer: Timer?
  
  @State private var wireGuardConfigError: String?
  
  @AppStorage("multiplayerHostDisplayName") private var hostDisplayName: String = UIDevice.current.name
  
  var body: some View {
    NavigationView {
      VStack {
        HStack {
          Spacer()
          Text("Multiplayer Options")
          Spacer()
          Button("Done") {
            var multiplayerConfig: MultiplayerConfig?
            if isHost && !numPlayers.isEmpty, let numPlayersInt = Int(numPlayers) {
              var mapName: String?
              if !startMap.isEmpty {
                mapName = startMap
              }
              var skillLevelVal: String?
              if !skillLevel.isEmpty {
                skillLevelVal = skillLevel
              }
              multiplayerConfig = .host(numPlayers: numPlayersInt, isDeathmatch: isDeathmatch, mapName: mapName, skillLevel: skillLevelVal)
            } else if !hostname.isEmpty {
              multiplayerConfig = .player(joinIpAddress: hostname)
            } else {
              multiplayerConfig = nil
            }
            viewModel.multiplayerConfig = multiplayerConfig
            dismiss()
          }
        }
        Form {
          Section {
            NavigationLink(destination: MultiplayerInstructionsView()) {
              Text("View Instructions")
            }
          }
          
          Section(header: Text("Hosting")) {
            Toggle("Start as Host", isOn: $isHost)
              .onChange(of: isHost) { newValue in
                if newValue && numPlayers.isEmpty {
                  numPlayers = "2"
                }
              }
            
            if isHost {
              TextField("Display Name", text: $hostDisplayName)
                .onChange(of: hostDisplayName) { newValue in
                  CentralRegistryClient.shared.serviceName = newValue
                }
              TextField("Number of players", text: $numPlayers)
                .keyboardType(.numberPad)
                .onReceive(Just(numPlayers)) { newValue in
                  let filtered = newValue.filter { "0123456789".contains($0) }
                  if filtered != newValue {
                    self.numPlayers = filtered
                  }
                }
                .onChange(of: numPlayers) { newValue in
                  // Remove leading zeros
                  var input = newValue.trimmingCharacters(in: CharacterSet(charactersIn: "0")).isEmpty ? "0" : newValue.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
                  
                  // Ensure the input is a valid number
                  if let intValue = Int(input), intValue >= 0 {
                    input = String(intValue)
                  } else {
                    input = ""
                  }
                  if input.count > 2 {
                    numPlayers = String(input.prefix(2))
                  }
                }
              TextField("Starting map (optional)", text: $startMap)
              TextField("Skill level (optional)", text: $skillLevel)
                .onReceive(Just(skillLevel)) { newValue in
                  let filtered = newValue.filter { "0123456789".contains($0) }
                  if filtered != newValue {
                    self.numPlayers = filtered
                  }
                }.onChange(of: skillLevel) { newValue in
                  if newValue.count > 2 {
                    skillLevel = String(newValue.prefix(2))
                  }
                }
              Toggle("Deathmatch", isOn: $isDeathmatch).disabled(!isHost)
            }
          }
          
          Section(header: HStack {
            Text("Online Multiplayer")
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(centralRegistry.isVPNConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(centralRegistry.isVPNConnected ? "Connected" : "Not Connected")
                    .font(.caption)
                    .foregroundColor(centralRegistry.isVPNConnected ? .green : .red)
            }
          }) {
            VStack(alignment: .leading, spacing: 8) {
              Text("For multiplayer over the internet, connect to our WireGuard VPN network.")
                .font(.small).foregroundStyle(.orange).lineSpacing(4)
              
              HStack {
                Spacer()
                Button(action: {
                  if let appStoreURL = URL(string: "https://apps.apple.com/us/app/wireguard/id1441195209") {
                    UIApplication.shared.open(appStoreURL)
                  }
                }) {
                  HStack {
                    Image(systemName: "arrow.down.app")
                    Text("Get WireGuard from the App Store")
                  }
                  .padding()
                  .frame(maxWidth: UIScreen.main.bounds.width * 0.65)
                  .background(Color.green)
                  .foregroundColor(.white)
                  .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
              }
              
              HStack {
                Spacer()
                Button(action: {
                  downloadWireGuardConfig()
                }) {
                  HStack {
                    Image(systemName: "arrow.down.circle")
                    Text("Download WireGuard Configuration")
                  }
                  .padding()
                  .frame(maxWidth: UIScreen.main.bounds.width * 0.65)
                  .background(Color.blue)
                  .foregroundColor(.white)
                  .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
              }
              
              if let error = wireGuardConfigError {
                Text(error)
                  .font(.caption)
                  .foregroundColor(.red)
                  .padding(.top, 4)
              }
              
              Text("Available Games")
                .foregroundStyle(.orange).lineSpacing(4)
              
              if !centralRegistry.isVPNConnected {
                Text("Please connect to our WireGuard VPN network first.").font(.small).foregroundStyle(.gray).padding()
              } else if centralRegistry.availableGames.isEmpty {
                Text("No VPN games found")
                  .font(.small)
                  .foregroundStyle(.gray)
                  .padding()
              } else {
                ForEach(centralRegistry.availableGames) { game in
                  Button {
                    hostname = game.ip_address
                    selectedGame = game
                    selectedService = nil
                  } label: {
                    HStack {
                      VStack(alignment: .leading) {
                        Text("\(game.host_name)")
                        Text("\(game.ip_address):\(game.port)").font(.small).foregroundStyle(.gray)
                        
                        if let iwadName = game.metadata["iwad"] {
                          Spacer()
                          ColoredText("Base game: ^[\(iwadName)](colored: 'red')").foregroundStyle(.yellow)
                        }
                        
                        if let modsCsv = game.metadata["mods"] {
                          Spacer()
                          Text("Mods used:").foregroundStyle(.yellow)
                          ForEach(modsCsv.split(separator: ","), id: \.self) { item in
                            Text(String(item)).foregroundStyle(.cyan).font(.small)
                          }
                        }
                      }
                      Spacer()
                      if selectedGame?.game_id == game.game_id {
                        Image(systemName: "checkmark")
                      }
                    }
                  }
                }
              }
              
            }
            .padding(.vertical, 8)
          }
          
          
          if !isHost {
            Section(header: Text("Local WiFi Network")) {
              Text("Hosts that started a game on GenZD on the same WiFi network will automatically appear here.\n\nChoose from the list or manually enter a hostname.").font(.small).foregroundStyle(.orange).lineSpacing(4)
              TextField("Hostname", text: $hostname) {
                selectedService = nil
              }
              
              List(browser.discoveredServices) { service in
                Section(header: Text("Local Network")) {
                  Button {
                    if let serviceHostname = service.netService.hostName {
                      hostname = serviceHostname
                      selectedService = service
                    }
                  } label: {
                    HStack {
                      VStack(alignment: .leading) {
                        Text("\(service.netService.name)")
                        Text("\(service.netService.hostName ?? "No hostname")").font(.small).foregroundStyle(.gray)
                        if let txtData = service.netService.txtRecordData() {
                          let txtDict = NetService.dictionary(fromTXTRecord: txtData)
                          if let iwadStrData = txtDict["iwad"],
                             let iwadName = String(data: iwadStrData, encoding: .utf8) {
                            Spacer()
                            ColoredText("Base game: ^[\(iwadName)](colored: 'red')").foregroundStyle(.yellow)
                          }
                          if let modsData = txtDict["mods"],
                             let modsCsv = String(data: modsData, encoding: .utf8) {
                            Spacer()
                            Text("Mods used:").foregroundStyle(.yellow)
                            ForEach(modsCsv.split(separator: ","), id: \.self) { item in
                              Text(item).foregroundStyle(.cyan).font(.small)
                            }
                          }
                        }
                      }
                      Spacer()
                      if selectedService?.id == service.id {
                        Image(systemName: "checkmark")
                      }
                    }
                  }
                }
              }
              
            }.disabled(isHost)
          }
        }
        
      }.onAppear {
        connectionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            // This will update isVPNConnected in the centralRegistry
            _ = centralRegistry.checkVPNStatus()
        }
        
        browser.startBrowsing()
        if let config = viewModel.multiplayerConfig {
          switch config {
          case .host(let numPlayers, let isDeathmatch, let mapName, let skillLevel):
            self.isHost = true
            self.numPlayers = "\(numPlayers)"
            self.isDeathmatch = isDeathmatch
            if let mapName {
              self.startMap = mapName
            }
            if let skillLevel {
              self.skillLevel = skillLevel
            }
          case .player(let joinIpAddress):
            self.isHost = false
            hostname = joinIpAddress
          }
        }
        
        centralRegistry.discoverGames()
        discoverTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
          centralRegistry.discoverGames()
        }
        discoverTimer?.fire()
      }.onDisappear {
        browser.stopBrowsing()
        discoverTimer?.invalidate()
        discoverTimer = nil
        connectionCheckTimer?.invalidate()
        connectionCheckTimer = nil
      }
    }
  }
  
  private func downloadWireGuardConfig() {
    wireGuardConfigError = nil
    
    let url = URL(string: "http://172.245.148.105:8000/generate-config")!
    var request = URLRequest(url: url)
    
    // Add basic auth
    let loginString = "admin:changeThisToASecurePassword"
    let loginData = loginString.data(using: .utf8)!
    let base64LoginString = loginData.base64EncodedString()
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if let error = error {
          self.wireGuardConfigError = "Download failed: \(error.localizedDescription)"
          return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
          self.wireGuardConfigError = "Server error: \(String(describing: (response as? HTTPURLResponse)?.statusCode))"
          return
        }
        
        guard let data = data else {
          self.wireGuardConfigError = "No data received"
          return
        }
        
        // The data is a WireGuard config file
        // Use UIActivityViewController to let the user save or share it
        let configString = String(data: data, encoding: .utf8) ?? ""
        
        // Create a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "GenZD-wireguard-\(dateString).conf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
          try configString.write(to: fileURL, atomically: true, encoding: .utf8)
          
          // Present share sheet
          let activityVC = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
          )
          
          // Find the current UIViewController to present from
          if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let rootVC = windowScene.windows.first?.rootViewController {
            var currentVC = rootVC
            while let presentedVC = currentVC.presentedViewController {
              currentVC = presentedVC
            }
            activityVC.popoverPresentationController?.sourceView = currentVC.view
            currentVC.present(activityVC, animated: true)
          }
        } catch {
          self.wireGuardConfigError = "Failed to save configuration: \(error.localizedDescription)"
        }
      }
    }.resume()
  }
  
}

struct MultiplayerInstructionsView: View {
  var body: some View {
    Form {
      Section(header: Text("Multiplayer Setup Instructions")) {
        ColoredText("""
^[You can either start a new game as a host, or join a game hosted by GenZD on another iOS device, or GZDoom running on a computer.](colored: 'orange')

^[Hosting a New Game](colored: 'yellow')

Enable ^["Start as Host"](colored: 'white') and specify the number of players. You may optionally specify a map name and/or skill level as well. The game mode will be co-op unless Deathmatch is enabled.

Once a host starts the multiplayer game, the host will be discoverable by other iOS devices running GenZD. 

^[Join an Existing Game](colored: 'yellow')

Wait for the host to start a multiplayer game, and the host's device name should appear in the "Join" section. Tap on the host to select it. The host information will also show the mods enabled, and you must ^[select the same mods as the host or the game may not run correctly](colored: 'red').

Press "Done" and select "Launch Now without saving"
""").lineSpacing(4).foregroundStyle(.gray)
      }
    }
  }
}
