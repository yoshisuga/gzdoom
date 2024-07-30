//
//  GamepadControl.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import Foundation

extension GamepadControl: Codable {
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
    case .select: return "SL"
    case .start: return "ST"
    case .dpad: return "D-Pad"
    case .leftMouseClick: return "LMB"
    case .rightMouseClick: return "RMB"
    default: return "unk"
    }
  }
}

//@objc enum GamepadControl: Int, Codable {
//  case A, B, X, Y
//  case L, R, LT, RT
//  case LS, RS
//  case select, start
//  case dpad
//  
//  var name: String {
//    switch self {
//    case .A: return "A"
//    case .B: return "B"
//    case .X: return "X"
//    case .Y: return "Y"
//    case .L: return "L"
//    case .R: return "R"
//    case .LT: return "LT"
//    case .RT: return "RT"
//    case .LS: return "LS"
//    case .RS: return "RS"
//    case .select: return "Select"
//    case .start: return "Start"
//    case .dpad: return "D-Pad"
//    }
//  }
//}

extension GamepadControl {
  var view: UIView {
    switch self {
    case .A, .B, .X, .Y, .L, .R, .LT, .RT, .LS, .RS, .select, .start, .leftMouseClick, .rightMouseClick:
      let view = GamepadButtonView(buttonName: self.name)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.tag = rawValue
      return view
    case .dpad:
      let view = DPadView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.tag = rawValue
      return view
    default:
      return UIView()
    }
  }
  
  static func createDefaultPositions(to view: UIView, buttonDelegate: GamepadButtonDelegate? = nil, dpadDelegate: DPadDelegate? = nil) {
    print("Creating default control positions...")
    let buttonA = GamepadControl.A.view
    buttonA.tag = GamepadControl.A.rawValue
    view.addSubview(buttonA)
    buttonA.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
    buttonA.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140).isActive = true
    (buttonA as? GamepadButtonView)?.delegate = buttonDelegate
    
    let buttonB = GamepadControl.B.view
    buttonB.tag = GamepadControl.B.rawValue
    view.addSubview(buttonB)
    buttonB.trailingAnchor.constraint(equalTo: buttonA.trailingAnchor).isActive = true
    buttonB.bottomAnchor.constraint(equalTo: buttonA.topAnchor, constant: 0).isActive = true
    (buttonB as? GamepadButtonView)?.delegate = buttonDelegate
    
    let buttonRT = GamepadControl.RT.view
    buttonRT.tag = GamepadControl.RT.rawValue
    view.addSubview(buttonRT)
    buttonRT.bottomAnchor.constraint(equalTo: buttonA.bottomAnchor, constant: -20).isActive = true
    buttonRT.trailingAnchor.constraint(equalTo: buttonA.leadingAnchor, constant: 4).isActive = true
    (buttonRT as? GamepadButtonView)?.delegate = buttonDelegate
    
    let buttonY = GamepadControl.Y.view
    buttonY.tag = GamepadControl.Y.rawValue
    view.addSubview(buttonY)
    buttonY.trailingAnchor.constraint(equalTo: buttonRT.leadingAnchor, constant: 4).isActive = true
    buttonY.bottomAnchor.constraint(equalTo: buttonRT.bottomAnchor, constant: -12).isActive = true
    (buttonY as? GamepadButtonView)?.delegate = buttonDelegate
    
    let buttonR = GamepadControl.R.view
    buttonR.tag = GamepadControl.R.rawValue
    view.addSubview(buttonR)
    buttonR.bottomAnchor.constraint(equalTo: buttonY.topAnchor, constant: 4).isActive = true
    buttonR.leadingAnchor.constraint(equalTo: buttonY.trailingAnchor, constant: -32).isActive = true
    (buttonR as? GamepadButtonView)?.delegate = buttonDelegate
    
    let buttonLT = GamepadControl.LT.view
    buttonLT.tag = GamepadControl.LT.rawValue
    view.addSubview(buttonLT)
    buttonLT.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48).isActive = true
    buttonLT.bottomAnchor.constraint(equalTo: buttonA.bottomAnchor, constant: -16).isActive = true
    (buttonLT as? GamepadButtonView)?.delegate = buttonDelegate
    
    let buttonRT2 = GamepadControl.RT.view
    buttonRT2.tag = GamepadControl.RT.rawValue
    view.addSubview(buttonRT2)
    buttonRT2.leadingAnchor.constraint(equalTo: buttonLT.trailingAnchor, constant: 16).isActive = true
    buttonRT2.bottomAnchor.constraint(equalTo: buttonLT.bottomAnchor).isActive = true
    (buttonRT2 as? GamepadButtonView)?.delegate = buttonDelegate
    
    let dpad = GamepadControl.dpad.view
    dpad.tag = GamepadControl.dpad.rawValue
    view.addSubview(dpad)
    dpad.bottomAnchor.constraint(equalTo: buttonLT.topAnchor, constant: 8).isActive = true
    dpad.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60).isActive = true
    (dpad as? DPadView)?.delegate = dpadDelegate
    
    let buttonL = GamepadControl.L.view
    buttonL.tag = GamepadControl.L.rawValue
    view.addSubview(buttonL)
    buttonL.leadingAnchor.constraint(equalTo: dpad.trailingAnchor, constant: -4).isActive = true
    buttonL.bottomAnchor.constraint(equalTo: buttonR.bottomAnchor).isActive = true
    (buttonL as? GamepadButtonView)?.delegate = buttonDelegate
  }
}


struct GamepadButtonPosition: Codable {
  let button: GamepadControl
  let originX: Float
  let originY: Float
  
  static let userDefaultsKey = "controlPositions"
}
