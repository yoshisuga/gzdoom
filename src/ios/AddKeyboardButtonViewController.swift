//
//  AddKeyboardButtonViewController.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 8/11/24.
//

import Foundation
import UIKit

class AddKeyboardButtonViewController: UIViewController {
  var didSelectControlClosure: ((GamepadControl) -> Void)?
  var didSwitchClosure: (() -> Void)?

  override func viewDidLoad() {
    let keyboardRow1 = UIStackView(arrangedSubviews: [
      GamepadButtonView(control: GamepadControl.kb_Esc, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F1, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F2, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F3, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F4, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F5, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F6, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F7, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F8, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F9, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F10, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F11, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F12, operationMode: .arranging, delegate: self),
    ])
    keyboardRow1.axis = .horizontal
    keyboardRow1.spacing = 0
    keyboardRow1.alignment = .center
    keyboardRow1.distribution = .equalSpacing
    
    let keyboardRow2 = UIStackView(arrangedSubviews: [
      GamepadButtonView(control: GamepadControl.kb_Tilde, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_1, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_2, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_3, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_4, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_5, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_6, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_7, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_8, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_9, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_0, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Minus, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Equal, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Backspace, operationMode: .arranging, delegate: self)
      ]
    )
    keyboardRow2.axis  = .horizontal
    keyboardRow2.spacing = 0
    keyboardRow2.alignment = .center
    
    let keyboardRow3 = UIStackView(arrangedSubviews: [
      GamepadButtonView(control: GamepadControl.kb_Tab, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_Q, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_W, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_E, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_R, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_T, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_Y, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_U, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_I, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_O, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_P, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_LeftBracket, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_RightBracket, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Backslash, operationMode: .arranging, delegate: self)
    ])
    keyboardRow3.axis = .horizontal
    keyboardRow3.spacing = 0
    keyboardRow3.alignment = .center

    let keyboardRow4 = UIStackView(arrangedSubviews: [
      GamepadButtonView(control: GamepadControl.KB_A, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_S, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_D, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_F, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_G, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_H, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_J, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_K, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_L, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Semicolon, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Quote, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Return, operationMode: .arranging, delegate: self)
    ])
    keyboardRow4.axis = .horizontal
    keyboardRow4.spacing = 0
    keyboardRow4.alignment = .center
    
    let keyboardRow5 = UIStackView(arrangedSubviews: [
      GamepadButtonView(control: GamepadControl.kb_Shift, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_Z, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_X, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_C, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_V, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_B, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_N, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.KB_M, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Comma, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Period, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Slash, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Home, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Insert, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_End, operationMode: .arranging, delegate: self)
    ])
    keyboardRow5.axis = .horizontal
    keyboardRow5.spacing = 0
    keyboardRow5.alignment = .center

    let keyboardRow6 = UIStackView(arrangedSubviews: [
      GamepadButtonView(control: GamepadControl.kb_Control, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Alt, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Space, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Up, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Down, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Left, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Right, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_Del, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_PageUp, operationMode: .arranging, delegate: self),
      GamepadButtonView(control: GamepadControl.kb_PageDown, operationMode: .arranging, delegate: self)
    ])
    keyboardRow6.axis = .horizontal
    keyboardRow6.spacing = 0
    keyboardRow6.alignment = .center
    keyboardRow6.distribution = .equalSpacing


    let keyboardRows = UIStackView(arrangedSubviews: [
      keyboardRow1,
      keyboardRow2,
      keyboardRow3,
      keyboardRow4,
      keyboardRow5,
      keyboardRow6
    ])
    keyboardRows.axis = .vertical
    keyboardRows.spacing = 2
    keyboardRows.alignment = .center
    keyboardRows.translatesAutoresizingMaskIntoConstraints = false
    
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(keyboardRows)
    keyboardRows.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    keyboardRows.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    keyboardRows.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    keyboardRows.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    keyboardRows.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    
    view.addSubview(scrollView)
    scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
  }
}

extension AddKeyboardButtonViewController: GamepadButtonDelegate {
  func gamepadButton(pressed button: GamepadButtonView, isMove: Bool) {
  }
  
  func gamepadButton(released button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {
    guard let releasedControl = GamepadControl(rawValue: button.tag) else {
      return
    }
    didSelectControlClosure?(releasedControl)
  }
}
