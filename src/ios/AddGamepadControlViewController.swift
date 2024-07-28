//
//  AddGamepadControlViewController.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import Foundation
import UIKit

class AddGamepadControlViewController: UIViewController {
  var didSelectControlClosure: ((GamepadControl) -> Void)?
  
  override func viewDidLoad() {
    let dpad = GamepadControl.dpad.view
    view.addSubview(dpad)
    dpad.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
    dpad.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48).isActive = true
    let buttonA = GamepadControl.A.view
    view.addSubview(buttonA)
    buttonA.centerYAnchor.constraint(equalTo: dpad.centerYAnchor).isActive = true
    buttonA.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
    let buttonB = GamepadControl.B.view
    view.addSubview(buttonB)
    buttonB.trailingAnchor.constraint(equalTo: buttonA.leadingAnchor, constant: 0).isActive = true
    buttonB.topAnchor.constraint(equalTo: buttonA.bottomAnchor, constant: 0).isActive = true
    let buttonX = GamepadControl.X.view
    view.addSubview(buttonX)
    buttonX.centerXAnchor.constraint(equalTo: buttonB.centerXAnchor).isActive = true
    buttonX.bottomAnchor.constraint(equalTo: buttonA.topAnchor, constant: 0).isActive = true
    let buttonY = GamepadControl.Y.view
    view.addSubview(buttonY)
    buttonY.trailingAnchor.constraint(equalTo: buttonX.leadingAnchor, constant: 0).isActive = true
    buttonY.centerYAnchor.constraint(equalTo: dpad.centerYAnchor).isActive = true
    let buttonL = GamepadControl.L.view
    view.addSubview(buttonL)
    buttonL.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
    buttonL.bottomAnchor.constraint(equalTo: dpad.topAnchor, constant: 16).isActive = true
    let buttonLT = GamepadControl.LT.view
    view.addSubview(buttonLT)
    buttonLT.leadingAnchor.constraint(equalTo: buttonL.leadingAnchor).isActive = true
    buttonLT.bottomAnchor.constraint(equalTo: buttonL.topAnchor, constant: -8).isActive = true
    let buttonR = GamepadControl.R.view
    view.addSubview(buttonR)
    buttonR.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
    buttonR.bottomAnchor.constraint(equalTo: dpad.topAnchor, constant: 16).isActive = true
    let buttonRT = GamepadControl.RT.view
    view.addSubview(buttonRT)
    buttonRT.trailingAnchor.constraint(equalTo: buttonR.trailingAnchor).isActive = true
    buttonRT.bottomAnchor.constraint(equalTo: buttonR.topAnchor, constant: -8).isActive = true
    let buttonSelect = GamepadControl.select.view
    view.addSubview(buttonSelect)
    buttonSelect.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
    buttonSelect.centerXAnchor.constraint(equalTo: dpad.centerXAnchor, constant: 48).isActive = true
    let buttonStart = GamepadControl.start.view
    view.addSubview(buttonStart)
    buttonStart.centerXAnchor.constraint(equalTo: buttonB.centerXAnchor, constant: -48).isActive = true
    buttonStart.bottomAnchor.constraint(equalTo: buttonSelect.bottomAnchor).isActive = true
    
    (buttonA as? GamepadButtonView)?.delegate = self
    (buttonB as? GamepadButtonView)?.delegate = self
    (buttonX as? GamepadButtonView)?.delegate = self
    (buttonY as? GamepadButtonView)?.delegate = self
    (buttonL as? GamepadButtonView)?.delegate = self
    (buttonLT as? GamepadButtonView)?.delegate = self
    (buttonR as? GamepadButtonView)?.delegate = self
    (buttonRT as? GamepadButtonView)?.delegate = self
    (dpad as? DPadView)?.delegate = self
  }
}

extension AddGamepadControlViewController: GamepadButtonDelegate {
  func gamepadButton(pressed button: GamepadButtonView) {
    guard let pressedControl = GamepadControl(rawValue: button.tag) else {
      return
    }
    print("Pressed control = \(pressedControl)")
  }
  
  func gamepadButton(released button: GamepadButtonView) {
    guard let releasedControl = GamepadControl(rawValue: button.tag) else {
      return
    }
    print("Released control = \(releasedControl)")
    didSelectControlClosure?(releasedControl)
  }
}

extension AddGamepadControlViewController: DPadDelegate {
  func dPad(_ dPadView: DPadView, didPress: DPadDirection) {
    print("pressed dpad")
  }
  
  func dPadDidRelease(_ dPadView: DPadView) {
    print("released dpad")
    didSelectControlClosure?(.dpad)
  }
}

