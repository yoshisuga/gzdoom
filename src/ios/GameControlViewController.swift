//
//  GameControlViewController.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import UIKit

class GameControlViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let joystick = JoystickView()
    joystick.translatesAutoresizingMaskIntoConstraints = false
    joystick.backgroundColor = .clear
    view.addSubview(joystick)
    joystick.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    joystick.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    joystick.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    joystick.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    joystick.delegate = self
    
    let aim = AimControlsView()
    aim.translatesAutoresizingMaskIntoConstraints = false
    aim.backgroundColor = .clear
    view.addSubview(aim)
    aim.leadingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    aim.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    aim.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    aim.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    aim.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadSavedControls()
  }
  
  private func loadSavedControls() {
    guard let saveData = UserDefaults.standard.data(forKey: GamepadButtonPosition.userDefaultsKey),
          let controlPositions = try? PropertyListDecoder().decode([GamepadButtonPosition].self, from: saveData) else { return }
    
    for controlView in view.subviews {
      if controlView is DPadView || controlView is GamepadButtonView {
        controlView.removeFromSuperview()
      }
    }
    
    for controlPos in controlPositions {
      let controlView = controlPos.button.view
      controlView.translatesAutoresizingMaskIntoConstraints = true
      controlView.tag = controlPos.button.rawValue
      let size: CGFloat = controlPos.button == .dpad ? 150 : 80
      controlView.frame = CGRect(x: CGFloat(controlPos.originX), y: CGFloat(controlPos.originY), width: size, height: size)
      view.addSubview(controlView)
      if let gamepadButton = controlView as? GamepadButtonView {
        gamepadButton.delegate = self
      } else if let dpad = controlView as? DPadView {
        dpad.delegate = self
      }
    }
  }
  
  @objc func arrangeButtonTapped(_ sender: UIButton) {
    let controller = ArrangeGamepadControlViewController()
    controller.onSaveClosure = {
      self.loadSavedControls()
    }
    present(controller, animated: true)
  }
}

extension GameControlViewController: JoystickDelegate {
  func joystickEnded() {
    guard let utils = IOSUtils.shared() else {
      return
    }
    utils.handleLeftThumbstickDirectionalInput(.up, isPressed: false)
    utils.handleLeftThumbstickDirectionalInput(.down, isPressed: false)
    utils.handleLeftThumbstickDirectionalInput(.right, isPressed: false)
    utils.handleLeftThumbstickDirectionalInput(.left, isPressed: false)
  }
  
  func joystickMoved(dx: Float, dy: Float) {
    guard let utils = IOSUtils.shared() else {
      return
    }
    let deadzoneThreshold: Float = 4.0

    if dx > deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.right, isPressed: true)
      utils.handleLeftThumbstickDirectionalInput(.left, isPressed: false)
    } else if dx < -deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.left, isPressed: true)
      utils.handleLeftThumbstickDirectionalInput(.right, isPressed: false)
    } else if dx >= -deadzoneThreshold && dx < deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.right, isPressed: false)
      utils.handleLeftThumbstickDirectionalInput(.left, isPressed: false)
    }
    
    if dy < -deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.up, isPressed: true)
      utils.handleLeftThumbstickDirectionalInput(.down, isPressed: false)
    } else if dy > deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.down, isPressed: true)
      utils.handleLeftThumbstickDirectionalInput(.up, isPressed: false)
    } else if dy >= -deadzoneThreshold && dy < deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.up, isPressed: false)
      utils.handleLeftThumbstickDirectionalInput(.down, isPressed: false)
    }
  }
}

extension GameControlViewController: AimControlsDelegate {
  func aimEnded() {
    MouseInputHolder.shared.deltaX = 0
    MouseInputHolder.shared.deltaY = 0
    guard let utils = IOSUtils.shared() else { return }
    utils.handleLeftMouseButton(withPressed: false)
  }
  
  func aimDidSingleTap() {
  }
  
  func aimDidDoubleTap() {
    guard let utils = IOSUtils.shared() else { return }
    utils.handleLeftMouseButton(withPressed: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      utils.handleLeftMouseButton(withPressed: false)
    }
  }
  
  func aimDidMove(dx: Float, dy: Float, isDoubleTap: Bool) {
    let mouseMoveX: Int = Int(dx)
    let mouseMoveY: Int = Int(dy)
    MouseInputHolder.shared.deltaX = mouseMoveX
    MouseInputHolder.shared.deltaY = mouseMoveY
    if isDoubleTap {
      guard let utils = IOSUtils.shared() else { return }
      utils.handleLeftMouseButton(withPressed: true)
    }
  }
}

extension GameControlViewController: GamepadButtonDelegate {
  func gamepadButton(pressed button: GamepadButtonView) {
    guard let utils = IOSUtils.shared(),
          let gamepadControl = GamepadControl(rawValue: button.tag) else {
      return
    }
    utils.handleGameControl(gamepadControl, isPressed: true)
  }
  
  func gamepadButton(released button: GamepadButtonView) {
    guard let utils = IOSUtils.shared(),
          let gamepadControl = GamepadControl(rawValue: button.tag) else {
      return
    }
    utils.handleGameControl(gamepadControl, isPressed: false)
  }
}

extension GameControlViewController: DPadDelegate {
  func dPad(_ dPadView: DPadView, didPress: DPadDirection) {
    guard let utils = IOSUtils.shared() else { return }
    utils.handleOverlayDPad(with: dPadView.currentDirection)
  }
  
  func dPadDidRelease(_ dPadView: DPadView) {
    guard let utils = IOSUtils.shared() else { return }
    utils.handleOverlayDPad(with: .none)
  }
}
