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
  
  @Environment(\.presentations) private var presentations
  
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
        }.padding()
        #if !os(tvOS)
          .border(.gray, width: 2)
        #endif
          .foregroundColor(.green)
        Spacer()
        Button("Cancel") {
          dismiss()
        }.padding()
        #if !os(tvOS)
          .border(.gray, width: 2)
        #endif
          .foregroundColor(.red)
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
      viewModel.saveLauncherConfig(name: configName, iwad: selectedIWAD, arguments: orderedArgs, ranAt: Date())
//      dismiss()
      presentations.forEach {
        $0.wrappedValue = nil
      }
    }.padding(.bottom)
  }
  
  func move(from source: IndexSet, to destination: Int) {
    orderedArgs.move(fromOffsets: source, toOffset: destination)
  }
}

struct LauncherConfigsView: View {
  @ObservedObject var viewModel: LauncherViewModel
  
  @State private var showSaveConfigSheet = false
  @State private var selectedConfig: LauncherConfig?
  
  @Binding var showToast: Bool
  @Binding var sortMode: LaunchConfigSortOrder
  @Binding var activeSheet: ActiveSheet?
  
  @State private var showMissingAlert = false
  @State private var showSearch = false
  @State private var searchText = ""
  
  var sortedConfigs: [LauncherConfig] {
    let configs = {
      switch sortMode {
      case .alphabetical:
        return viewModel.savedConfigs.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
      case .recent:
        return viewModel.savedConfigs.sorted(by: { a, b in
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
    }()
    if searchText.isEmpty {
      return configs
    } else {
      return configs.filter { $0.name.localizedStandardContains(searchText) }
    }
  }
  
  var body: some View {
    VStack {
        List {
          Section(header: HStack {
            Text("Launch Configurations").font(.body).foregroundColor(.yellow)
            Spacer()
            Button(action: {
              withAnimation {
                showSearch.toggle()
                if showSearch == false {
                  searchText = ""
                }
              }
            }, label: {
              Image(systemName: "magnifyingglass").foregroundStyle(.yellow)
            })
          }) {
            if showSearch {
              TextField("Search...", text: $searchText)
                .background(Color.black.opacity(0.4))
                .foregroundColor(.cyan)
                .listRowBackground(Color.clear)
                .font(.selected)
                .transition(.slide)
                .animation(.easeInOut(duration: 1.0), value: showSearch)
              
            }
            ForEach(sortedConfigs) { config in
              Button(config.name) {
                viewModel.currentConfig = config
                if !viewModel.validateFiles() {
                  showMissingAlert = true
                  return
                }
                viewModel.launchActionClosure?(viewModel.arguments)
                viewModel.saveLauncherConfig(name: config.name, iwad: config.baseIWAD, arguments: config.arguments, ranAt: Date())
              }.foregroundColor(.red)
              #if os(iOS)
                .swipeActions {
                Button(role: .destructive) {
                  viewModel.deleteLauncherConfigs([config])
                } label: {
                  Image(systemName: "trash")
                }
                Button {
                  selectedConfig = config
                  viewModel.currentConfig = config
                  showToast = true
                } label: {
                  Image(systemName: "pencil")
                }
              }
              #endif
                .listRowBackground(Color.clear)
            }.onDelete { indexSet in
              let configsToDelete = indexSet.map{ viewModel.savedConfigs[$0] }
              viewModel.deleteLauncherConfigs(configsToDelete)
            }
          }
        }.listStyle(PlainListStyle()).overlay(Group {
          if sortedConfigs.isEmpty && searchText.isEmpty {
            VStack {
              Text("No saved configurations.")
              Button("Add a Launch Configuration") {
                activeSheet = .addLauncherConfig
              }.buttonStyle(.bordered).foregroundColor(.yellow).font(.body)
            }
          }
      })
//      }
    }.sheet(item: $selectedConfig) { config in
      CreateLaunchConfigView(viewModel: viewModel, isEditing: true)
    }.alert("Cannot launch: Missing or Invalid Files in Launch Configuration", isPresented: $showMissingAlert) {
      Button("OK", role: .cancel) { }
    }
  }
}
