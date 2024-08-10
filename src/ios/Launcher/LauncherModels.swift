//
//  LauncherModels.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import Foundation

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
  var lastRanAt: Date?
  
  var documentsPath: String {
    #if os(tvOS)
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].path
    #else
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
    #endif
  }
  
  var baseIWAD: GZDoomFile {
    return GZDoomFile(displayName: baseIWADName, fullPath: "\(documentsPath)/\(baseIWADName)")
  }
  
  var arguments: [GZDoomFile] {
    return argumentsByName.map { GZDoomFile(displayName: $0, fullPath: "\(documentsPath)/\($0)") }
  }
  
  init(name: String, baseIWAD: GZDoomFile, arguments: [GZDoomFile]) {
    self.name = name
    self.baseIWADName = baseIWAD.displayName
    self.argumentsByName = arguments.map { $0.displayName }
  }
}

enum MultiplayerConfig: Hashable, Codable, Equatable {
  case host(numPlayers: Int, isDeathmatch: Bool)
  case player(joinIpAddress: String)
  
  var arguments: [String] {
    var args = [String]()
    switch self {
    case .host(let numPlayers, let isDeathmatch):
      args.append("-host")
      args.append("\(numPlayers)")
      if isDeathmatch {
        args.append("-deathmatch")
      }
    case .player(let joinIpAddress):
      args.append("-join")
      args.append(joinIpAddress)
    }
    return args
  }  
}
