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
        Section(header: Text("Important Note")) {
          Text("This is still a work-in-progress. Joining an existing game seems to work but hosting currently does not.")
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
          TextField("Hostname", text: $hostname)
        }.disabled(isHost)
      }
    }
  }
}
