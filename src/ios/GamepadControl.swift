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
    case .kb_Esc: return "ESC"
    case .KB_F1: return "F1"
    case .KB_F2: return "F2"
    case .KB_F3: return "F3"
    case .KB_F4: return "F4"
    case .KB_F5: return "F5"
    case .KB_F6: return "F6"
    case .KB_F7: return "F7"
    case .KB_F8: return "F8"
    case .KB_F9: return "F9"
    case .KB_F10: return "F10"
    case .KB_F11: return "F11"
    case .KB_F12: return "F12"
    case .kb_Tab: return "Tab"
    case .kb_Tilde: return "~"
    case .KB_1: return "1"
    case .KB_2: return "2"
    case .KB_3: return "3"
    case .KB_4: return "4"
    case .KB_5: return "5"
    case .KB_6: return "6"
    case .KB_7: return "7"
    case .KB_8: return "8"
    case .KB_9: return "9"
    case .KB_0: return "0"
    case .kb_Minus: return "-"
    case .kb_Equal: return "="
    case .kb_Backspace: return "BSP"
    case .KB_Q: return "Q"
    case .KB_W: return "W"
    case .KB_E: return "E"
    case .KB_R: return "R"
    case .KB_T: return "T"
    case .KB_Y: return "Y"
    case .KB_U: return "U"
    case .KB_I: return "I"
    case .KB_O: return "O"
    case .KB_P: return "P"
    case .kb_LeftBracket: return "["
    case .kb_RightBracket: return "]"
    case .KB_A: return "A"
    case .KB_S: return "S"
    case .KB_D: return "D"
    case .KB_F: return "F"
    case .KB_G: return "G"
    case .KB_H: return "H"
    case .KB_J: return "J"
    case .KB_K: return "K"
    case .KB_L: return "L"
    case .kb_Semicolon: return ";"
    case .kb_Quote: return ";"
    case .kb_Return: return ";"
    case .kb_Shift: return "SHF"
    case .KB_Z: return "Z"
    case .KB_X: return "X"
    case .KB_C: return "C"
    case .KB_V: return "V"
    case .KB_B: return "B"
    case .KB_N: return "N"
    case .KB_M: return "M"
    case .kb_Comma: return ","
    case .kb_Period: return "."
    case .kb_Slash: return "/"
    case .kb_Control: return "CTR"
    case .kb_Alt: return "ALT"
    case .kb_Space: return "SPC"
    case .kb_Up: return "SFMONO_UP"
    case .kb_Down: return "SFMONO_DOWN"
    case .kb_Left: return "SFMONO_LEFT"
    case .kb_Right: return "SFMONO_RIGHT"
    case .kb_Home: return "HME"
    case .kb_Insert: return "INS"
    case .kb_End: return "END"
    case .kb_Del: return "DEL"
    case .kb_PageUp: return "PGU"
    case .kb_PageDown: return "PGD"
    case .kb_Backslash: return "\\"
    default: return "unk"
    }
  }
  
  var buttonType: GamepadButtonType {
    switch self {
    case .A, .B, .X, .Y, .L, .R, .LT, .RT, .LS, .RS, .select, .start, .dpad, .leftMouseClick, .rightMouseClick:
      return .gamepad
    default:
      return .keyboard
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
    case .dpad:
      let view = DPadView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.tag = rawValue
      return view
    default:
      let view = GamepadButtonView(buttonName: self.name, buttonType: buttonType)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.tag = rawValue
      return view
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

struct GamepadButtonColor: Codable {
  static let userDefaultsKey = "colorPositions"
  
  var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 1.0
  
  var uiColor : UIColor {
      return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
  }
  
  init(uiColor : UIColor) {
      uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
  }
}

struct GamepadButtonPosition: Codable {
  let button: GamepadControl
  let originX: Float
  let originY: Float
  
  static let userDefaultsKey = "controlPositions"
}
