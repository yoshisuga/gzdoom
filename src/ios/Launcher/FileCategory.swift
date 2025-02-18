//
//  FileCategory.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 2/8/25.
//

import Foundation
import SwiftUI

enum FileCategory: CaseIterable, Codable, Hashable {
  case all
  case addOns
  case totalConversions
  case gameplay
  case maps
  case monsters
  case weapons
  case graphics
  case ui
  case music
  case companions
  case unknown(String)
  
  var title: String {
    switch self {
    case .all: return "All"
    case .totalConversions: return "Total Conversions"
    case .addOns: return "Add-Ons"
    case .companions: return "Companions"
    case .music: return "Audio"
    case .maps: return "Maps"
    case .monsters: return "Monsters"
    case .weapons: return "Weapons"
    case .graphics: return "Graphics"
    case .gameplay: return "Gameplay"
    case .ui: return "User Interface/HUD"
    case .unknown(let custom): return "Unknown (\(custom))"
    }
  }
  
  var color: Color {
    switch self {
    case .all: return .red
    case .totalConversions: return .blue
    case .addOns: return .gray
    case .companions: return .brown
    case .maps: return .orange
    case .music: return .purple
    case .monsters: return .yellow
    case .weapons: return Color(red: 0.780, green: 0.082, blue: 0.522)
    case .graphics: return .green
    case .gameplay: return Color(red: 0.0, green: 0.749, blue: 1.0)
    case .ui: return .pink
    case .unknown: return .black
    }
  }
  
  var isUnknown: Bool {
    if case .unknown = self {
      return true
    }
    return false
  }
  
  static func == (lhs: FileCategory, rhs: FileCategory) -> Bool {
    return lhs.title == rhs.title
  }
  
  static var allCases: [FileCategory] {
    return [
      .all,
      .addOns,
      .totalConversions,
      .gameplay,
      .maps,
      .monsters,
      .weapons,
      .graphics,
      .ui,
      .music,
      .companions
    ]
  }

  func hash(into hasher: inout Hasher) {
      switch self {
      case .unknown(let original):
          hasher.combine("unknown_\(original)")
      default:
          hasher.combine("\(self)")
      }
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let valueDict = try container.decode([String: [String: String]].self)
    
    if let firstKey = valueDict.keys.first {
      if let category = FileCategory.allCases.first(where: { "\($0)" == firstKey }) {
        self = category
      } else {
        self = .unknown(firstKey)
        print("Unknown category: \(firstKey)")
        print("Files for unknown category:")
      }
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Dictionary is empty.")
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
    if let data = UserDefaults.standard.data(forKey: "categoryMap") {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Saved JSON Data: \(jsonString)")
        }
    }
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
