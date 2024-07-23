//
//  LauncherViewModel.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import Combine
import Foundation
import ZIPFoundation

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
  
  @Published var savedConfigs = [LauncherConfig]()
  
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
        
        if itemNS == "gzdoom.ini" {
          if !fm.fileExists(atPath: "\(documentsPath)/Preferences/gzdoom.ini") {
            let sourceUrl = Bundle.main.bundleURL.appendingPathComponent(itemNS as String)
            var destUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Preferences")
            if !fm.fileExists(atPath: destUrl.path) {
              do {
                try fm.createDirectory(at: destUrl, withIntermediateDirectories: true)
              } catch {
                print("gzdoom.ini create pref dir failed: \(error)")
              }
            }
            destUrl = destUrl.appendingPathComponent("gzdoom.ini")
            do {
              try fm.copyItem(at: sourceUrl, to: destUrl)
            } catch {
              print("gzdoom.ini file copy error: \(error)")
            }
          }
          continue
        }
        
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
    refreshSavedConfigs()
  }
  
  var defaultLauncherConfig: LauncherConfig {
    let demo = "\(Bundle.main.bundlePath)/GenZDDemo.ipk3"
    return LauncherConfig(
      name: "GenZD Tutorial and Showcase",
      baseIWAD: GZDoomFile(displayName: "GenZDDemo.ipk3", fullPath: demo),
      arguments: [GZDoomFile]()
    )
  }
  
  func refreshSavedConfigs() {
    savedConfigs = getSavedLauncherConfigs()
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
    refreshSavedConfigs()
  }
  
  func getSavedLauncherConfigs() -> [LauncherConfig] {
    guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
      return []
    }
    guard var savedConfigs = try? PropertyListDecoder().decode([LauncherConfig].self, from: data) else {
      UserDefaults.standard.removeObject(forKey: userDefaultsKey)
      return []
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
    refreshSavedConfigs()
  }
  
  func validateFiles() -> Bool {
    guard let selectedIWAD else { return false }
    let fm = FileManager.default
    if !fm.fileExists(atPath: selectedIWAD.fullPath) {
      return false
    }
    for externalFile in externalFiles {
      if !fm.fileExists(atPath: externalFile.fullPath) {
        return false
      }
    }
    let baseGameFullPath = selectedIWAD.fullPath as NSString
    let ext = baseGameFullPath.pathExtension.lowercased()
    if ext == "zip" || ext == "ipk3" {
      var containsIwadinfoLump = false
      do {
        
        let archive = try Archive(url: URL(filePath: selectedIWAD.fullPath), accessMode: .read)
        for entry in archive {
          let filename = entry.path.lowercased() as NSString
          if filename.lastPathComponent.starts(with: "iwadinfo") {
            containsIwadinfoLump = true
            break
          }
        }
      } catch {
        print("validate: archive create error: \(error)")
      }
      print("validate: is zip or ipk3 and found iwadinfo: \(containsIwadinfoLump)")
      if !containsIwadinfoLump {
        return false
      }
    }
    return true
  }
}
