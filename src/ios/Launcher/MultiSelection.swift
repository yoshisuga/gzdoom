//
//  MultiSelection.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import SwiftUI

struct MultipleSelectionRow: View {
  var file: GZDoomFile
  var isSelected: Bool
  var action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Text(file.displayName).foregroundColor(isSelected ? .red : .orange)
        if isSelected {
          Spacer()
          Image(systemName: "checkmark").foregroundColor(.red)
        }
      }
    }
  }
}

struct MultiplayerSheetView: View {
  var body: some View {
    VStack {
      Text("Multiplayer Config")
    }
  }
}
