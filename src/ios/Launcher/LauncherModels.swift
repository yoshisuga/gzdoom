//
//  LauncherModels.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import Foundation

enum OriginalDoomEngineGame: String, Codable {
  case doom = "doom.wad"
  case doom2 = "doom2.wad"
  case doomUltimate = "doomu.wad"
  case plutonia = "plutonia.wad"
  case tnt = "tnt.wad"
  case hexen = "hexen.wad"
  case heretic = "heretic.wad"
  case strife = "strife1.wad"
  case chex = "chex.wad"
  case freedoom1 = "freedoom1.wad"
  case freedoom2 = "freedoom2.wad"
  
  var title: String {
    switch self {
    case .doom: return "DOOM"
    case .doom2: return "DOOM II"
    case .doomUltimate: return "DOOM Ultimate"
    case .plutonia: return "The Plutonia Experiment"
    case .tnt: return "TNT: Evilution"
    case .hexen: return "Hexen"
    case .heretic: return "Heretic"
    case .strife: return "Strife: Quest for the Sigil"
    case .chex: return "Chex Quest"
    case .freedoom1: return "FreeDoom: Phase 1"
    case .freedoom2: return "FreeDoom: Phase 2"
    }
  }
  
  init?(filename: String) {
    let lowerfilename = filename.lowercased()
    self.init(rawValue: lowerfilename)
  }
  
  static func filename(from title: String) -> String? {
      switch title {
      case "DOOM": return self.doom.rawValue
      case "DOOM II": return self.doom2.rawValue
      case "DOOM Ultimate": return self.doomUltimate.rawValue
      case "The Plutonia Experiment": return self.plutonia.rawValue
      case "TNT: Evilution": return self.tnt.rawValue
      case "Hexen": return self.hexen.rawValue
      case "Heretic": return self.heretic.rawValue
      case "Strife: Quest for the Sigil": return self.strife.rawValue
      case "Chex Quest": return self.chex.rawValue
      case "FreeDoom: Phase 1": return self.freedoom1.rawValue
      case "FreeDoom: Phase 2": return self.freedoom2.rawValue
      default: return nil
      }
  }
}

struct GZDoomFile: Identifiable, Hashable, Codable {
  let fullPath: String
  
  var filename: String {
    (fullPath as NSString).lastPathComponent
  }
  
  var displayName: String {
    if let game = OriginalDoomEngineGame(filename: filename) {
      return game.title
    }
    return filename
  }
  
  var id: String { filename }
  
  // Used only for the list view model
  var category: FileCategory? = .addOns
  
  var fileAddedDate = Date(timeIntervalSince1970: 0)
  
  var originalDoomEngineGame: OriginalDoomEngineGame? {
    OriginalDoomEngineGame(filename: filename)
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(filename)
  }
  
  // Equatable conformance based on filename property
  static func == (lhs: GZDoomFile, rhs: GZDoomFile) -> Bool {
    return lhs.filename == rhs.filename
  }
  
  init(fullPath: String) {
    self.fullPath = fullPath
    let fileURL = URL(fileURLWithPath: fullPath)
    if let resourceValues = try? fileURL.resourceValues(forKeys: [.addedToDirectoryDateKey]) {
      fileAddedDate = resourceValues.addedToDirectoryDate ?? Date(timeIntervalSince1970: 0)
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case fullPath
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    fullPath = try container.decode(String.self, forKey: .fullPath)
    category = .addOns // Default category for decoding
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(fullPath, forKey: .fullPath)
  }
}

struct LauncherConfig: Identifiable, Hashable, Codable, Equatable {
  let name: String
  let baseIWADName: String
  let argumentsByName: [String]
  var id: String { name }
  var lastRanAt: Date?
  
  var documentsPath: String {
    #if os(tvOS)
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].path
    #else
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    #endif
  }
  
  var baseIWAD: GZDoomFile {
    // Have to reconstitute this because the documentsPath changes in an update
    return GZDoomFile(fullPath: "\(documentsPath)/\(baseIWADName)")
  }
  
  var arguments: [GZDoomFile] {
    return argumentsByName.map { GZDoomFile(fullPath: "\(documentsPath)/\($0)") }
  }
  
  init(name: String, baseIWAD: GZDoomFile, arguments: [GZDoomFile]) {
    self.name = name
    self.baseIWADName = baseIWAD.filename
    self.argumentsByName = arguments.map { $0.filename }
  }
}

enum MultiplayerConfig: Hashable, Codable, Equatable {
  case host(numPlayers: Int, isDeathmatch: Bool, mapName: String?, skillLevel: String?)
  case player(joinIpAddress: String)
  
  var arguments: [String] {
    var args = [String]()
    switch self {
    case .host(let numPlayers, let isDeathmatch, let mapName, let skillLevel):
      args.append("-host")
      args.append("\(numPlayers)")
      if isDeathmatch {
        args.append("-deathmatch")
      }
      if let mapName {
        args.append("+map")
        args.append(mapName)
      }
      if let skillLevel {
        args.append("-skill")
        args.append(skillLevel)
      }
    case .player(let joinIpAddress):
      args.append("-join")
      args.append(joinIpAddress)
    }
    args.append("-extratic")
    return args
  }  
}
