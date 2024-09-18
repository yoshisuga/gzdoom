//
//  MultiplayerSheetView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import Combine
import SwiftUI

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
          Section(header: Text("Join")) {
            Text("Hosts that started a game on GenZD on the same WiFi network will automatically appear here.\n\nChoose from the list or manually enter a hostname.").font(.small).foregroundStyle(.orange).lineSpacing(4)
            TextField("Hostname", text: $hostname) {
              selectedService = nil
            }
            
            List(browser.discoveredServices) { service in
              Section(header: Text("Discovered Hosts")) {
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
      }.onAppear {
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
      }.onDisappear {
        browser.stopBrowsing()
      }
    }
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
