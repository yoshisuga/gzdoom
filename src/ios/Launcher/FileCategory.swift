//
//  FileCategory.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 2/8/25.
//

import Foundation
import SwiftUI

enum FileCategory: CaseIterable, Codable {
  case all
  case addOns
  case totalConversions
  case gameplay
  case maps
  case monsters
  case weapons
  case graphics
  case music
  case randomizers
  case demos

  var title: String {
    switch self {
    case .all: return "All"
    case .totalConversions: return "Total Conversions"
    case .addOns: return "Add-Ons"
    case .demos: return "Demos"
    case .music: return "Audio"
    case .maps: return "Maps"
    case .monsters: return "Monsters"
    case .weapons: return "Weapons"
    case .graphics: return "Graphics"
    case .gameplay: return "Gameplay"
    case .randomizers: return "Randomizers"
    }
  }
  
  var color: Color {
    switch self {
    case .all: return .red
    case .totalConversions: return .blue
    case .addOns: return .gray
    case .demos: return .brown
    case .maps: return .orange
    case .music: return .purple
    case .monsters: return .yellow
    case .weapons: return Color(red: 0.780, green: 0.082, blue: 0.522)
    case .graphics: return .green
    case .gameplay: return Color(red: 0.0, green: 0.749, blue: 1.0)
    case .randomizers: return .pink
    }
  }
}

class FileCategoryManager: ObservableObject {
  let userDefaultsKey = "categoryMap"
  @Published var categoryMap: [FileCategory: [GZDoomFile]] = [:]
  
  init() {
    loadFromUserDefaults()
  }
  
  private func loadFromUserDefaults() {
    guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
    do {
      categoryMap = try JSONDecoder().decode([FileCategory: [GZDoomFile]].self, from: data)
    } catch {
      print("Could not decode category map from user defaults: \(error)")
    }
  }
  
  func save() {
    do {
      let data = try JSONEncoder().encode(categoryMap)
      UserDefaults.standard.set(data, forKey: "categoryMap")
    } catch {
      print("Failed to save category map: \(error)")
    }
  }
  
  func assign(_ file: inout GZDoomFile, to category: FileCategory, in externalFiles: inout [GZDoomFile]) {
    if category == .all { return }
    if categoryMap[category] == nil {
      categoryMap[category] = []
    }
    // Remove file from any existing category
    for (key, files) in categoryMap {
      if let index = files.firstIndex(of: file) {
        categoryMap[key]?.remove(at: index)
      }
    }
    // Assign file to the new category
    if let index = externalFiles.firstIndex(of: file) {
      externalFiles[index].category = category
    }
    categoryMap[category]?.append(file)
    DispatchQueue.main.async { [weak self] in
      self?.save()
    }
  }
  
  func reset() {
    categoryMap = [:]
    UserDefaults.standard.removeObject(forKey: userDefaultsKey)
  }
}
