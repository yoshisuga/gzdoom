//
//  LauncherViewModel.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import Combine

class LauncherViewModel: ObservableObject {
  @Published var iWadFiles = [GZDoomFile]()
  @Published var externalFiles = [GZDoomFile]()
  
  @Published var selectedIWAD: GZDoomFile?
  @Published var selectedExternalFiles = [GZDoomFile]()
  
  var multiplayerConfig: MultiplayerConfig?
  
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
    var args = wads + mods
    if let multiplayerConfig {
      args.append(contentsOf: multiplayerConfig.arguments)
    }
    args.append("use_joystick")
    args.append("1")
    return args
  }
  
  var launchActionClosure: (([String]) -> Void)?
  
  func setup() {
    let fm = FileManager.default
    let documentsPath = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    var iwads = [GZDoomFile]()
    var mods = [GZDoomFile]()
    print("Documents path: \(documentsPath)")
    
    // Create a file in the documents path so it appears in the Files app
    if !fm.fileExists(atPath: "\(documentsPath)/Add Your Files Here.txt") {
      let text = """
      Add your wads and mods file in this directory using the Files app!
      
      Allowed extensions: .wad, iwad, .pk3, .ipk3, .ipk7, .zip
      """
      try? text.write(toFile: "\(documentsPath)/Add Your Files Here.txt", atomically: true, encoding: .utf8)
    }
    
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
          if pathExt.lowercased() == "wad" || pathExt.lowercased() == "ipk3" {
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
  
  func saveLauncherConfig(name: String, iwad: GZDoomFile, arguments: [GZDoomFile], ranAt: Date? = nil) {
    var launcherConfig = LauncherConfig(name: name, baseIWAD: iwad, arguments: arguments)
    launcherConfig.lastRanAt = ranAt
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
