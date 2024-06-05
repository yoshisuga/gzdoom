//
//  GameControllerHandler.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 2/25/23.
//

import Foundation
import GameController

@objc class GameControllerHandler: NSObject {
  @objc static let shared = GameControllerHandler()
  
  var controller: GCController?
  
  private var virtualController: GCVirtualController?
  private var reconnectVirtual = true
  
  override init() {
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(gameControllerConnected(_:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(gameControllerDisconnected(_:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
  }
  
  @objc var virtualConnected: Bool { virtualController != nil }
  
  @objc func toggleVirtual() {
    if virtualConnected {
      disableVirtual()
    } else {
      reconnectVirtual = true
      setupVirtualIfNeeded()
    }
  }
  
  @objc func setupVirtualIfNeeded() {
    if GCController.controllers().isEmpty {
      let config = GCVirtualController.Configuration()
      config.elements = [
        GCInputLeftThumbstick,
        GCInputRightThumbstick,
        GCInputButtonA,
        GCInputButtonB,
        GCInputButtonX,
        GCInputButtonY,
        GCInputLeftTrigger,
        GCInputRightTrigger,
        GCInputLeftShoulder,
        GCInputRightShoulder
      ]
      virtualController = GCVirtualController(configuration: config)
      virtualController?.connect()
    }
  }
  
  @objc func disableVirtual() {
    reconnectVirtual = false
    virtualController?.disconnect()
    virtualController = nil
  }
  
  @objc func enableVirtual() {
    reconnectVirtual = true
    setupVirtualIfNeeded()
  }
  
  @objc func gameControllerConnected(_ sender: Notification) {
    guard let connectedController = sender.object as? GCController else {
      return
    }
    print("GCController connected: \(connectedController.vendorName ?? "Controller of Unknown Vendor")")
    if controller == connectedController {
      print("Controller already connected, skipping setup")
      return
    }
    if virtualController != nil && virtualController?.controller != connectedController {
      // a physical controller connected; disable the virtual
      disableVirtual()
    }
    setupController(connectedController)
  }
  
  @objc func gameControllerDisconnected(_ sender: Notification) {
    if reconnectVirtual {
      setupVirtualIfNeeded()
    }
  }
  
  func setupController(_ controllerToSetup: GCController) {
    // Just use the first connected controller for now; this might be different for tvOS, etc
    guard let utils = IOSUtils.shared() else {
      print("GameControllerHandler: no controller to setup!")
      return
    }
    
    guard let gamepad = controllerToSetup.extendedGamepad else { return }

    gamepad.leftThumbstick.valueChangedHandler = { dpad, x, y in
      let movementDeadzone: Float = 0.2
      if x > movementDeadzone {
        utils.handleLeftThumbstickDirectionalInput(.right, isPressed: true)
        utils.handleLeftThumbstickDirectionalInput(.left, isPressed: false)
      } else if x < -movementDeadzone {
        utils.handleLeftThumbstickDirectionalInput(.left, isPressed: true)
        utils.handleLeftThumbstickDirectionalInput(.right, isPressed: false)
      } else if x >= -movementDeadzone && x < movementDeadzone {
        utils.handleLeftThumbstickDirectionalInput(.right, isPressed: false)
        utils.handleLeftThumbstickDirectionalInput(.left, isPressed: false)
      }
      if y > movementDeadzone {
        utils.handleLeftThumbstickDirectionalInput(.up, isPressed: true)
        utils.handleLeftThumbstickDirectionalInput(.down, isPressed: false)
      } else if y < -movementDeadzone {
        utils.handleLeftThumbstickDirectionalInput(.down, isPressed: true)
        utils.handleLeftThumbstickDirectionalInput(.up, isPressed: false)
      } else if y >= -movementDeadzone && y < movementDeadzone {
        utils.handleLeftThumbstickDirectionalInput(.up, isPressed: false)
        utils.handleLeftThumbstickDirectionalInput(.down, isPressed: false)
      }
    }

    gamepad.buttonA.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.buttonB.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.buttonX.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.buttonY.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.rightShoulder.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.leftShoulder.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.rightTrigger.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.leftTrigger.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.dpad.up.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.dpad.down.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.dpad.left.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.dpad.right.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.buttonOptions?.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.buttonMenu.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.leftThumbstickButton?.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }
    gamepad.rightThumbstickButton?.valueChangedHandler = { button, _, pressed in
      utils.handleGameControllerInput(for: gamepad, button: button, isPressed: pressed)
    }

    controller = controllerToSetup
  }
  
  @objc func handleInput() {
    // Hook into the GZDoom polling handler every frame by polling our game controller for thumbstick values to mimic mouse movement
    guard let utils = IOSUtils.shared(), let controller, let extendedGamepad = controller.extendedGamepad else { return }
    let mouseMoveX: Int = Int(extendedGamepad.rightThumbstick.xAxis.value * 20)
    let mouseMoveY: Int = Int(extendedGamepad.rightThumbstick.yAxis.value * 20) * -1
    utils.mouseMoveWith(x: mouseMoveX, y: mouseMoveY)
  }
}
