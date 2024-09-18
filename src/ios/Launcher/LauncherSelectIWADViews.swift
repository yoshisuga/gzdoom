//
//  LauncherSelectIWADViews.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import SwiftUI

struct SelectIWADView: View {
  @ObservedObject var viewModel: LauncherViewModel
  
  var namespace: Namespace.ID
  
  var body: some View {
    Text("Select the base game file:").foregroundColor(.cyan)
    List(viewModel.iWadFiles.sorted(by: { fileA, fileB in
      return fileA.displayName.lowercased() < fileB.displayName.lowercased()
    })) { file in
      Button {
        withAnimation {
          viewModel.selectedIWAD = file
        }
        viewModel.externalFiles.removeAll(where: { $0.displayName == file.displayName })
      } label: {
        Text(file.displayName)
          .matchedGeometryEffect(id: file.displayName, in: namespace)
          .font(viewModel.selectedIWAD?.displayName == file.displayName ? .selected : .body)
      }.foregroundColor(.yellow)
      
//      Button(file.displayName) {
//        viewModel.selectedIWAD = file
//        viewModel.externalFiles.removeAll(where: { $0.displayName == file.displayName })
//      }.foregroundColor(.yellow)
    }.listStyle(PlainListStyle())
  }
}

struct IWADSelectedView: View {
  @ObservedObject var viewModel: LauncherViewModel

  @Environment(\.presentations) private var presentations
  @State private var activeSheet: ActiveSheet?

  @State private var configAction: LaunchConfigAction = .none
  
  @State private var showMissingAlert = false
  
  let selected: GZDoomFile

  var namespace: Namespace.ID

  var body: some View {
    VStack {
      Text(selected.displayName)
        .matchedGeometryEffect(id: selected.displayName, in: namespace)
        .foregroundColor(.yellow)
        .font(viewModel.selectedIWAD?.displayName == selected.displayName ? .selected : .body)
        .frame(maxWidth: .infinity)
      Text("Selected").foregroundColor(.green)
      Button("Choose different base game") {
        withAnimation {
          viewModel.selectedIWAD = nil
        }
        viewModel.externalFiles.append(selected)
      }.buttonStyle(.bordered).padding(.horizontal, 8).frame(height: 50)
      Button("Save Launch Configuration") {
        activeSheet = .saveLaunchConfig
      }.buttonStyle(.bordered).padding(.horizontal, 8).foregroundColor(.green).frame(height: 50)
      Button("Launch Now without saving") {
        if !viewModel.validateFiles() {
          showMissingAlert = true
          return
        }
        viewModel.launchActionClosure?(viewModel.arguments)
      }.buttonStyle(.bordered).foregroundColor(.yellow).padding(.horizontal, 8).frame(height: 50)
      Button {
        activeSheet = .multiplayer
      } label: {
        if let multiplayerConfig = viewModel.multiplayerConfig {
          let multiplayerDetail: String = {
            switch multiplayerConfig {
            case .host(let numPlayers, let isDeathmatch, _, _):
              return "\(numPlayers)P \(isDeathmatch ? "Deathmatch" : "Co-op") Host"
            case .player:
              return "Join Game"
            }
          }()
          ColoredText("^[Multiplayer: ](colored: 'cyan') ^[\(multiplayerDetail)](colored: 'white')")
        } else {
          ColoredText("^[Multiplayer Options](colored: 'cyan')")
        }
      }.buttonStyle(.bordered).padding(.horizontal, 8)
        .font(.small)
    }.sheet(item: $activeSheet) { item in
      switch item {
      case .saveLaunchConfig:
        LauncherConfigSheetView(viewModel: viewModel).environment(\.presentations, presentations + [$activeSheet])
      case .multiplayer:
        MultiplayerSheetView(viewModel: viewModel)
      default:
        EmptyView()
      }
    }.alert("Cannot launch: Missing or Invalid Files in Launch Configuration", isPresented: $showMissingAlert) {
      Button("OK", role: .cancel) { }
    }
  }
}

struct AnimatableFontModifier: AnimatableModifier {
    var size: CGFloat
    var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }

    func body(content: Content) -> some View {
      content.font(.custom("PerfectDOSVGA437", size: size))
    }
}

extension View {
    func animatableFont(size: CGFloat) -> some View {
        self.modifier(AnimatableFontModifier(size: size))
    }
}
