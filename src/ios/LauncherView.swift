//
//  LauncherView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 2/19/23.
//

import Foundation
import SwiftUI

struct GZDoomFile: Identifiable, Hashable, Codable {
  let displayName: String
  let fullPath: String
  var id: String { displayName }
}

struct LauncherConfig: Identifiable, Hashable, Codable, Equatable {
  let name: String
  let baseIWADName: String
  let argumentsByName: [String]
  var id: String { name }
  
  var baseIWAD: GZDoomFile {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    return GZDoomFile(displayName: baseIWADName, fullPath: "\(documentsPath)/\(baseIWADName)")
  }
  
  var arguments: [GZDoomFile] {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    return argumentsByName.map { GZDoomFile(displayName: $0, fullPath: "\(documentsPath)/\($0)") }
  }
  
  init(name: String, baseIWAD: GZDoomFile, arguments: [GZDoomFile]) {
    self.name = name
    self.baseIWADName = baseIWAD.displayName
    self.argumentsByName = arguments.map { $0.displayName }
  }
}

class LauncherViewModel: ObservableObject {
  @Published var iWadFiles = [GZDoomFile]()
  @Published var externalFiles = [GZDoomFile]()
  
  @Published var selectedIWAD: GZDoomFile?
  @Published var selectedExternalFiles = [GZDoomFile]()
  
  var currentConfig: LauncherConfig? {
    didSet {
      if let currentConfig {
        selectedIWAD = currentConfig.baseIWAD
        selectedExternalFiles = currentConfig.arguments
      }
    }
  }
  
  private let userDefaultsKey = "configs"
  
  let excludedFiles = [
    "game_widescreen_gfx.pk3",
    "game_support.pk3",
    "lights.pk3",
    "brightmaps.pk3",
    "gzdoom.pk3"
  ]
  
  var arguments: [String] {
    guard let selectedIWAD else { return [] }
    let wads = ["-iwad", selectedIWAD.fullPath]
    var mods = selectedExternalFiles.map{ $0.fullPath }
    if mods.count > 0 {
      mods.insert("-file", at: 0)
    }
    return wads + mods
  }
  
  var launchActionClosure: (([String]) -> Void)?
  
  func setup() {
    let fm = FileManager.default
    let documentsPath = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    var iwads = [GZDoomFile]()
    var mods = [GZDoomFile]()
    print("Documents path: \(documentsPath)")
    do {
      let docItems = try fm.contentsOfDirectory(atPath: documentsPath)
      let bundleItems = try fm.contentsOfDirectory(atPath: Bundle.main.bundlePath)
      for item in docItems {
        let itemNS = item as NSString
        let pathExt = itemNS.pathExtension
        let displayName = itemNS.lastPathComponent
        let file = GZDoomFile(displayName: displayName, fullPath: "\(documentsPath)/\(item)")
        if pathExt.lowercased() == "wad" || pathExt.lowercased() == "iwad" || pathExt.lowercased() == "ipk3" {
          iwads.append(file)
          if pathExt.lowercased() == "wad" {
            mods.append(file)
          }
        } else if ["pk3", "ipk3", "ipk7", "zip"].contains(pathExt.lowercased()) {
          mods.append(file)
        }
      }
      for item in bundleItems {
        let itemNS = item as NSString
        let pathExt = itemNS.pathExtension
        let displayName = itemNS.lastPathComponent
        let file = GZDoomFile(displayName: displayName, fullPath: item)
        if pathExt.lowercased() == "wad" || pathExt.lowercased() == "iwad" {
          iwads.append(file)
          if pathExt.lowercased() == "wad" {
            mods.append(file)
          }
        } else if ["pk3", "ipk3", "ipk7", "zip"].contains(pathExt.lowercased()) && !excludedFiles.contains(item) {
          mods.append(file)
        }
      }
      
      iWadFiles = iwads
      externalFiles = mods
    } catch {
      print("Could not read docs dir: \(error)")
    }
  }
  
  func saveLauncherConfig(name: String, iwad: GZDoomFile, arguments: [GZDoomFile]) {
    let launcherConfig = LauncherConfig(name: name, baseIWAD: iwad, arguments: arguments)
    var existingConfigs = [LauncherConfig]()
    if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
       existingConfigs = try! PropertyListDecoder().decode([LauncherConfig].self, from: data)
    }
    if let existingIndex = existingConfigs.firstIndex(where: { $0.name == launcherConfig.name }) {
      existingConfigs[existingIndex] = launcherConfig
    } else {
      existingConfigs.append(launcherConfig)
    }
    existingConfigs.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
    if let saveData = try? PropertyListEncoder().encode(existingConfigs) {
      UserDefaults.standard.set(saveData, forKey: userDefaultsKey)
    }
  }
  
  func getSavedLauncherConfigs() -> [LauncherConfig] {
    guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
      return [LauncherConfig]()
    }
    guard var savedConfigs = try? PropertyListDecoder().decode([LauncherConfig].self, from: data) else {
      UserDefaults.standard.removeObject(forKey: userDefaultsKey)
      return [LauncherConfig]()
    }
    savedConfigs.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
    return savedConfigs
  }
  
  func deleteLauncherConfigs(_ configs: [LauncherConfig]) {
    var savedConfigs = getSavedLauncherConfigs()
    for configToDelete in configs {
      savedConfigs.removeAll(where: {$0 == configToDelete})
    }
    guard let saveData = try? PropertyListEncoder().encode(savedConfigs) else {
      return
    }
    UserDefaults.standard.set(saveData, forKey: userDefaultsKey)
  }
}

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
  @State private var showSaveConfigSheet = false
  let selected: GZDoomFile
  
  var body: some View {
    VStack {
      Spacer()
      Text(selected.displayName).foregroundColor(.yellow).font(.selected)
      Text("Selected").foregroundColor(.green)
      Spacer()
      Button("Save this configuration") {
        showSaveConfigSheet.toggle()
      }.sheet(isPresented: $showSaveConfigSheet) {
        LauncherConfigSheetView(viewModel: viewModel)
      }.padding().foregroundColor(.cyan).border(.gray, width: 2)
      Spacer()
      Button("Choose a different IWAD") {
        viewModel.selectedIWAD = nil
        viewModel.externalFiles.append(selected)
      }.padding().border(.gray, width: 2)
      Spacer()
      Button("Launch GZDoom") {
        print("GZDoom Launch!")
        viewModel.launchActionClosure?(viewModel.arguments)
      }.font(.actionButton).foregroundColor(.red).padding().border(.gray, width: 2)
//      Text(viewModel.arguments.joined(separator: " ")).font(.system(size: 9, design: .monospaced))
    }
  }
}

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
  
  @Binding var launcherMode: LauncherMode
  
  var body: some View {
    VStack {
      if configs.isEmpty {
        Spacer()
        Text("No saved configurations. Create one in the '\(LauncherMode.launcher.rawValue)' tab!").foregroundColor(.gray)
        Spacer()
      } else {
        List {
          ForEach(configs) { config in
            Button(config.name) {
              viewModel.currentConfig = config
              viewModel.launchActionClosure?(viewModel.arguments)
            }.foregroundColor(.red).swipeActions {
              Button(role: .destructive) {
                viewModel.deleteLauncherConfigs([config])
              } label: {
                Image(systemName: "trash")
              }
              Button {
                selectedConfig = config
                viewModel.currentConfig = config
                launcherMode = .launcher
//                showSaveConfigSheet.toggle()
              } label: {
                Image(systemName: "pencil")
              }
            }
          }.onDelete { indexSet in
            let configsToDelete = indexSet.map{ configs[$0] }
            viewModel.deleteLauncherConfigs(configsToDelete)
          }
        }.listStyle(PlainListStyle())
      }
    }.sheet(item: $selectedConfig) { config in
      LauncherConfigSheetView(viewModel: viewModel)
    }.onAppear {
      configs = viewModel.getSavedLauncherConfigs()
    }
  }
}

enum LauncherMode: String {
  case launcher = "Launcher", savedConfigs = "Saved Configurations"
}

struct LauncherView: View {
  @ObservedObject var viewModel: LauncherViewModel
  @State private var selections = [GZDoomFile]()
  @State private var launcherMode: LauncherMode = .launcher
  
  var body: some View {
    VStack {
      Text("GZDoom").font(.largeTitle).padding(.bottom).foregroundColor(.red)
      Picker("Launcher Mode", selection: $launcherMode) {
        ForEach([LauncherMode.launcher, LauncherMode.savedConfigs], id: \.self) {
          Text($0.rawValue).font(.body)
        }
      }.pickerStyle(.segmented)
      if launcherMode == .launcher {
        HStack {
          VStack {
            if let selectedIWAD = viewModel.selectedIWAD {
              IWADSelectedView(viewModel: viewModel, selected: selectedIWAD)
            } else {
              SelectIWADView(viewModel: viewModel)
            }
          }.frame(maxWidth: .infinity)
          VStack {
            Text("External Files/Mods").foregroundColor(.cyan)
            List {
              ForEach(viewModel.externalFiles.sorted(by: {$0.displayName.lowercased() < $1.displayName.lowercased() }), id:\.self) { file in
                MultipleSelectionRow(file: file, isSelected: viewModel.selectedExternalFiles.contains(file)) {
                  if viewModel.selectedExternalFiles.contains(file) {
                    viewModel.selectedExternalFiles.removeAll(where: { $0 == file })
                  }
                  else {
                    viewModel.selectedExternalFiles.append(file)
                  }
                }
              }
            }.frame(maxHeight: .infinity).listStyle(PlainListStyle())
          }
        }.padding(.top).padding(.bottom)
      } else {
        LauncherConfigsView(viewModel: viewModel, launcherMode: $launcherMode)
      }
      Text("Ported to iOS by Yoshi Sugawara, 2023").font(.small).foregroundColor(.red)
    }.padding([.bottom], 4)
    .onAppear {
      viewModel.setup()
    }.font(.body)
  }
  
  init(viewModel: LauncherViewModel, selections: [GZDoomFile] = [GZDoomFile](), launcherMode: LauncherMode = .launcher) {
    self.viewModel = viewModel
    self.selections = selections
    self.launcherMode = launcherMode
    UISegmentedControl.appearance().setTitleTextAttributes([.font : UIFont(name: "PerfectDOSVGA437", size: 20)!], for: .normal)
  }
}

struct LauncherView_Previews: PreviewProvider {
  static var viewModel: LauncherViewModel {
    let vm = LauncherViewModel()
    vm.iWadFiles = [
      GZDoomFile(displayName: "doom.wad", fullPath: "doom.wad"),
      GZDoomFile(displayName: "doom2.wad", fullPath: "doom2.wad"),
      GZDoomFile(displayName: "finaldoom.wad", fullPath: "finaldoom.wad")
    ]
    vm.externalFiles = [
      GZDoomFile(displayName: "brutal.pk3", fullPath: "brutal.pk3"),
      GZDoomFile(displayName: "zelda.pk3", fullPath: "zelda.pk3"),
    ]
    return vm
  }
    static var previews: some View {
        LauncherView(viewModel: viewModel)
    }
}

@objc class LauncherViewController: UIViewController {
  let viewModel: LauncherViewModel
  
  init(viewModel: LauncherViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    print("PRINT FONTS")
    for family in UIFont.familyNames {
         print(family)
         for names in UIFont.fontNames(forFamilyName: family){
         print("== \(names)")
         }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.launchActionClosure = { [weak self] arguments in
      self?.startSDLMain(withArgs: arguments)
    }
    let launcherView = LauncherView(viewModel: viewModel)
    let hostingController = UIHostingController(rootView: launcherView)
    addChild(hostingController)
    hostingController.didMove(toParent: self)
    let hostingView = hostingController.view!
    view.addSubview(hostingView)
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingView.topAnchor.constraint(equalTo: view.topAnchor),
      hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
}

@objc class LauncherViewControllerFactory: NSObject {
  @objc static func create() -> UIViewController {
    let viewModel = LauncherViewModel()
    let viewController = LauncherViewController(viewModel: viewModel)
    return viewController
  }
}

extension Font {
  public static var largeTitle: Font {
    Font.custom("PerfectDOSVGA437", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
  }
  
  public static var headline: Font {
    Font.custom("PerfectDOSVGA437", size: 20)
  }
  
  public static var body: Font {
    Font.custom("PerfectDOSVGA437", size: 20)
  }
  
  public static var selected: Font {
    Font.custom("PerfectDOSVGA437", size: 24)
  }
  
  public static var actionButton: Font {
    Font.custom("PerfectDOSVGA437", size: 32)
  }
  
  public static var small: Font {
    Font.custom("PerfectDOSVGA437", size: 16)
  }
}
