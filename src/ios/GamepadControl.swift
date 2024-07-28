//
//  GamepadControl.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import Foundation

enum GamepadControl: Int, Codable {
  case A, B, X, Y
  case L, R, LT, RT
  case LS, RS
  case select, start
  case dpad
  
  var name: String {
    switch self {
    case .A: return "A"
    case .B: return "B"
    case .X: return "X"
    case .Y: return "Y"
    case .L: return "L"
    case .R: return "R"
    case .LT: return "LT"
    case .RT: return "RT"
    case .LS: return "LS"
    case .RS: return "RS"
    case .select: return "Select"
    case .start: return "Start"
    case .dpad: return "D-Pad"
    }
  }
}

extension GamepadControl {
  var view: UIView {
    switch self {
    case .A, .B, .X, .Y, .L, .R, .LT, .RT, .LS, .RS, .select, .start:
      let view = GamepadButtonView(buttonName: self.name)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.tag = rawValue
      return view
    case .dpad:
      let view = DPadView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.tag = rawValue
      return view
    }
  }
}


struct GamepadButtonPosition: Codable {
  let button: GamepadControl
  let originX: Float
  let originY: Float
  
  static let userDefaultsKey = "controlPositions"
}
