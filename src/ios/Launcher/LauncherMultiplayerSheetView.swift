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

  var onDismiss: ((MultiplayerConfig?) -> Void)?
  
  @State private var isHost = false
  @State private var numPlayers = ""
  @State private var isDeathmatch = false
  @State private var hostname = ""

  @State private var selectedService: DiscoveredService?
  
  @StateObject private var browser = BonjourServiceBrowser()
  
  var body: some View {
    VStack {
      HStack {
        Spacer()
        Text("Multiplayer Options")
        Spacer()
        Button("Done") {
          var multiplayerConfig: MultiplayerConfig?
          if isHost && !numPlayers.isEmpty, let numPlayersInt = Int(numPlayers) {
            multiplayerConfig = .host(numPlayers: numPlayersInt, isDeathmatch: isDeathmatch)
          } else if !hostname.isEmpty {
            multiplayerConfig = .player(joinIpAddress: hostname)
          } else {
            multiplayerConfig = nil
          }
          onDismiss?(multiplayerConfig)
          dismiss()
        }
      }
      Form {
        Section(header: Text("Instructions")) {
          ColoredText("""
You can either start a new game as a host, or join a game hosted by GenZD on another iOS device, or GZDoom running on a computer.

Hosting

Joining
""")
          Text("This feature is currently experimental. Joining an existing game seems to work but hosting may have issues.")
            .foregroundColor(.orange)
        }
        Section(header: Text("Hosting")) {
          Toggle("Start as Host", isOn: $isHost)
          TextField("Number of players", text: $numPlayers)
            .keyboardType(.numberPad)
            .onReceive(Just(numPlayers)) { newValue in
              let filtered = newValue.filter { "0123456789".contains($0) }
              if filtered != newValue {
                  self.numPlayers = filtered
              }
            }
          Toggle("Deathmatch", isOn: $isDeathmatch).disabled(!isHost)
        }
        Section(header: Text("Join")) {
          TextField("Hostname", text: $hostname) {
            selectedService = nil
          }
          
          List(browser.discoveredServices) { service in
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
                }
                Spacer()
                if selectedService?.id == service.id {
                  Image(systemName: "checkmark")
                }
              }
            }
          }
          
        }.disabled(isHost)
      }
    }.onAppear {
      browser.startBrowsing()
    }.onDisappear {
      browser.stopBrowsing()
    }
  }
}
