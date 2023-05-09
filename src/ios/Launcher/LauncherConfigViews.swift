//
//  LauncherConfigViews.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import SwiftUI

struct LauncherConfigSheetView: View {
  @Environment(\.dismiss) var dismiss
  @State private var orderedArgs = [GZDoomFile]()
  @ObservedObject var viewModel: LauncherViewModel
  
  @State var saveAlertDisplayed = false
  @State var launcherConfigSaveName = ""
  
  var body: some View {
    VStack {
      Text("Base Game: \(viewModel.selectedIWAD?.displayName ?? "None")").foregroundColor(.yellow)
      Spacer()
      Text("External Files (drag to reorder load order):")
      if orderedArgs.isEmpty {
        Spacer()
        Text("No external files/mods added.").foregroundColor(.gray).frame(maxHeight: .infinity)
        Spacer()
      } else {
        List {
          ForEach(orderedArgs, id: \.self) { arg in
            Text(arg.displayName)
          }
          .onMove(perform: move)
        }
      }
      HStack {
        Spacer()
        Button("Save Launch Configuration") {
          withAnimation {
            saveAlertDisplayed = true
          }
        }.padding().border(.gray, width: 2)
        Spacer()
        Button("Cancel") {
          dismiss()
        }.padding().border(.gray, width: 2)
        Spacer()
      }
    }.onAppear {
      if let currentConfig = viewModel.currentConfig {
        launcherConfigSaveName = currentConfig.name
      }
      orderedArgs = viewModel.selectedExternalFiles
    }.textFieldAlert(isPresented: $saveAlertDisplayed, title: "Enter a name:", text: $launcherConfigSaveName) { configName in
      guard let selectedIWAD = viewModel.selectedIWAD else {
        return
      }
      viewModel.saveLauncherConfig(name: configName, iwad: selectedIWAD, arguments: orderedArgs)
      dismiss()
    }.padding(.bottom)
  }
  
  func move(from source: IndexSet, to destination: Int) {
    orderedArgs.move(fromOffsets: source, toOffset: destination)
  }
}

struct LauncherConfigsView: View {
  @ObservedObject var viewModel: LauncherViewModel
  @State private var configs = [LauncherConfig]()
  
  @State private var showSaveConfigSheet = false
  @State private var selectedConfig: LauncherConfig?
  
  @Binding var showToast: Bool
  @Binding var sortMode: LaunchConfigSortOrder
  
  var sortedConfigs: [LauncherConfig] {
    switch sortMode {
    case .alphabetical:
      return configs.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
    case .recent:
      return configs.sorted(by: { a, b in
        if a.lastRanAt == nil && b.lastRanAt != nil {
          return false
        } else if a.lastRanAt != nil && b.lastRanAt == nil {
          return true
        } else if a.lastRanAt == nil && b.lastRanAt == nil {
          return true
        } else {
          return a.lastRanAt! > b.lastRanAt!
        }
      })
    }
  }
  
  var body: some View {
    VStack {
      if configs.isEmpty {
        Spacer()
        Text("No saved configurations. Tap the + button above to create one now!").foregroundColor(.gray)
        Spacer()
      } else {
        List {
          Section(header: Text("Launcher Configurations").foregroundColor(.yellow)) {
            ForEach(sortedConfigs) { config in
              Button(config.name) {
                viewModel.currentConfig = config
                viewModel.launchActionClosure?(viewModel.arguments)
                viewModel.saveLauncherConfig(name: config.name, iwad: config.baseIWAD, arguments: config.arguments, ranAt: Date())
              }.foregroundColor(.red).swipeActions {
                Button(role: .destructive) {
                  viewModel.deleteLauncherConfigs([config])
                } label: {
                  Image(systemName: "trash")
                }
                Button {
                  selectedConfig = config
                  viewModel.currentConfig = config
                  showToast = true
                  //                showSaveConfigSheet.toggle()
                } label: {
                  Image(systemName: "pencil")
                }
              }
            }.onDelete { indexSet in
              let configsToDelete = indexSet.map{ configs[$0] }
              viewModel.deleteLauncherConfigs(configsToDelete)
            }
          }
        }.listStyle(PlainListStyle())
      }
    }.sheet(item: $selectedConfig) { config in
      CreateLaunchConfigView(viewModel: viewModel, isEditing: true)
    }.onAppear {
      configs = viewModel.getSavedLauncherConfigs()
    }
  }
}
