//
//  LauncherSelectIWADViews.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import SwiftUI

struct SelectIWADView: View {
  @ObservedObject var viewModel: LauncherViewModel
  var body: some View {
    Text("Select the base game file:").foregroundColor(.cyan)
    List(viewModel.iWadFiles.sorted(by: { fileA, fileB in
      return fileA.displayName.lowercased() < fileB.displayName.lowercased()
    })) { file in
      Button(file.displayName) {
        viewModel.selectedIWAD = file
        viewModel.externalFiles.removeAll(where: { $0.displayName == file.displayName })
      }.foregroundColor(.yellow)
    }.listStyle(PlainListStyle())
  }
}

struct IWADSelectedView: View {
  @ObservedObject var viewModel: LauncherViewModel
  @State private var activeSheet: ActiveSheet?

  let selected: GZDoomFile
  
  enum ActiveSheet: Identifiable {
    case save, multiplayer
    var id: Int { hashValue }
  }
  
  var body: some View {
    VStack {
      Text(selected.displayName).foregroundColor(.yellow).font(.selected)
      Text("Selected").foregroundColor(.green)
      Button("Multiplayer Options") {
        activeSheet = .multiplayer
      }.padding().foregroundColor(.cyan).border(.gray, width: 2)
      HStack {
        Button("Save config") {
          activeSheet = .save
        }.padding().foregroundColor(.green).border(.gray, width: 2)
        Button("Back") {
          viewModel.selectedIWAD = nil
          viewModel.externalFiles.append(selected)
        }.padding().border(.gray, width: 2)
      }
      Button("Launch GZDoom") {
        print("GZDoom Launch!")
        viewModel.launchActionClosure?(viewModel.arguments)
      }.font(.actionButton).foregroundColor(.red).padding().border(.gray, width: 2)
    }.sheet(item: $activeSheet) { item in
      switch item {
      case .save:
        LauncherConfigSheetView(viewModel: viewModel)
      case .multiplayer:
        MultiplayerSheetView { config in
          viewModel.multiplayerConfig = config
        }
      }
    }
  }
}
