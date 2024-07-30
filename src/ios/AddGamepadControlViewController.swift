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
  var didCloseClosure: (() -> Void)?
  
  let instructionsLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 2
    label.text = "Tap a button or D-Pad\nto add it to your touch controls."
    label.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    label.textAlignment = .center
    return label
  }()
  
  let closeButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
    configuration.baseForegroundColor = .white
    configuration.baseBackgroundColor = .darkGray
    var container = AttributeContainer()
    container.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    configuration.attributedTitle = AttributedString("Close", attributes: container)
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override func viewDidLoad() {
    let dpad = GamepadControl.dpad.view
    view.addSubview(dpad)
    dpad.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
    dpad.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48).isActive = true
    let buttonA = GamepadControl.A.view
    view.addSubview(buttonA)
    buttonA.centerYAnchor.constraint(equalTo: dpad.centerYAnchor).isActive = true
    buttonA.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30).isActive = true
    let buttonB = GamepadControl.B.view
    view.addSubview(buttonB)
    buttonB.trailingAnchor.constraint(equalTo: buttonA.leadingAnchor, constant: 24).isActive = true
    buttonB.topAnchor.constraint(equalTo: buttonA.bottomAnchor, constant: -24).isActive = true
    let buttonX = GamepadControl.X.view
    view.addSubview(buttonX)
    buttonX.centerXAnchor.constraint(equalTo: buttonB.centerXAnchor).isActive = true
    buttonX.bottomAnchor.constraint(equalTo: buttonA.topAnchor, constant: 24).isActive = true
    let buttonY = GamepadControl.Y.view
    view.addSubview(buttonY)
    buttonY.trailingAnchor.constraint(equalTo: buttonX.leadingAnchor, constant: 24).isActive = true
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
    buttonSelect.leadingAnchor.constraint(equalTo: dpad.trailingAnchor, constant: 36).isActive = true
    let buttonStart = GamepadControl.start.view
    view.addSubview(buttonStart)
    buttonStart.trailingAnchor.constraint(equalTo: buttonB.leadingAnchor, constant: -48).isActive = true
    buttonStart.bottomAnchor.constraint(equalTo: buttonSelect.bottomAnchor).isActive = true
    
    let leftClick = GamepadControl.leftMouseClick.view
    view.addSubview(leftClick)
    leftClick.centerXAnchor.constraint(equalTo: buttonSelect.centerXAnchor).isActive = true
    leftClick.bottomAnchor.constraint(equalTo: buttonSelect.topAnchor, constant: -8).isActive = true
    
    let rightClick = GamepadControl.rightMouseClick.view
    view.addSubview(rightClick)
    rightClick.centerXAnchor.constraint(equalTo: buttonStart.centerXAnchor).isActive = true
    rightClick.bottomAnchor.constraint(equalTo: buttonStart.topAnchor, constant: -8).isActive = true
    
    (buttonA as? GamepadButtonView)?.delegate = self
    (buttonB as? GamepadButtonView)?.delegate = self
    (buttonX as? GamepadButtonView)?.delegate = self
    (buttonY as? GamepadButtonView)?.delegate = self
    (buttonL as? GamepadButtonView)?.delegate = self
    (buttonLT as? GamepadButtonView)?.delegate = self
    (buttonR as? GamepadButtonView)?.delegate = self
    (buttonRT as? GamepadButtonView)?.delegate = self
    (leftClick as? GamepadButtonView)?.delegate = self
    (rightClick as? GamepadButtonView)?.delegate = self
    (dpad as? DPadView)?.delegate = self
    
    view.addSubview(instructionsLabel)
    instructionsLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 36).isActive = true
    instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    view.addSubview(closeButton)
    closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    closeButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 32).isActive = true
    closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), for: .touchUpInside)
  }
  
  @objc func closeButtonPressed(_ sender: UIButton) {
    didCloseClosure?()
  }
}

extension AddGamepadControlViewController: GamepadButtonDelegate {
  func gamepadButton(pressed button: GamepadButtonView, isMove: Bool) {
    guard let pressedControl = GamepadControl(rawValue: button.tag) else {
      return
    }
  }
  
  func gamepadButton(released button: GamepadButtonView) {
    guard let releasedControl = GamepadControl(rawValue: button.tag) else {
      return
    }
    didSelectControlClosure?(releasedControl)
  }
}

extension AddGamepadControlViewController: DPadDelegate {
  func dPad(_ dPadView: DPadView, didPress: DPadDirection) {
  }
  
  func dPadDidRelease(_ dPadView: DPadView) {
    didSelectControlClosure?(.dpad)
  }
}

