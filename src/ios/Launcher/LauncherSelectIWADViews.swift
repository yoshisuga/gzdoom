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
      Button("Save Launch Config") {
        activeSheet = .saveLaunchConfig
      }.padding().foregroundColor(.green)
      #if !os(tvOS)
        .border(.gray, width: 2)
      #endif
      Button("Back") {
        withAnimation {
          viewModel.selectedIWAD = nil
        }
        viewModel.externalFiles.append(selected)
      }.padding()
      #if !os(tvOS)
        .border(.gray, width: 2)
      #endif
      Spacer()
      Button("Launch Now without saving") {
        if !viewModel.validateFiles() {
          showMissingAlert = true
          return
        }
        viewModel.launchActionClosure?(viewModel.arguments)
      }.foregroundColor(.red).padding()
      #if !os(tvOS)
        .border(.gray, width: 2)
      #endif
      Button("Multiplayer Options") {
        activeSheet = .multiplayer
      }.padding().foregroundColor(.cyan)
      #if !os(tvOS)
        .border(.gray, width: 2)
      #endif
        .font(.small)
    }.sheet(item: $activeSheet) { item in
      switch item {
      case .saveLaunchConfig:
        LauncherConfigSheetView(viewModel: viewModel).environment(\.presentations, presentations + [$activeSheet])
      case .multiplayer:
        MultiplayerSheetView { config in
          viewModel.multiplayerConfig = config
        }
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
