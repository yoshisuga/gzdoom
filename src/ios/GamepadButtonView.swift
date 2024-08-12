//
//  GamepadButtonView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 6/4/24.
//

import Foundation
import UIKit

protocol GamepadButtonDelegate: AnyObject {
  func gamepadButton(began button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?)
  func gamepadButton(moved button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?)
  func gamepadButton(pressed button: GamepadButtonView, isMove: Bool)
  func gamepadButton(released button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?)
}

extension GamepadButtonDelegate {
  func gamepadButton(began button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {}
  func gamepadButton(moved button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {}
}

enum GamepadButtonType {
  case gamepad, keyboard
  
  var imageName: String {
    switch self {
    case .gamepad: return "button"
    case .keyboard: return "kb-button"
    }
  }
  
  var defaultSize: CGFloat {
    return 80
  }
  
  var sizeForAddingControl: CGFloat {
    switch self {
    case .gamepad: return defaultSize
    case .keyboard: return 40
    }
  }
}

enum GamepadButtonTypeOperationMode {
  case normal, arranging
}

class GamepadButtonView: UIView {
  let imageView: UIImageView
  private let buttonLabel: UILabel
  
  let buttonName: String
  let buttonType: GamepadButtonType
  var operationMode: GamepadButtonTypeOperationMode
  
  weak var delegate: GamepadButtonDelegate?
  
  convenience init(
    control: GamepadControl,
    operationMode: GamepadButtonTypeOperationMode = .normal,
    delegate: GamepadButtonDelegate? = nil
  ) {
    self.init(buttonName: control.name, buttonType: control.buttonType, operationMode: operationMode, delegate: delegate, tag: control.rawValue)
  }
  
  init(
    buttonName: String,
    buttonType: GamepadButtonType = .gamepad,
    operationMode: GamepadButtonTypeOperationMode = .normal,
    delegate: GamepadButtonDelegate? = nil,
    tag: Int? = nil
  ) {
    self.buttonName = buttonName
    self.buttonType = buttonType
    self.operationMode = operationMode
    self.delegate = delegate
    imageView = UIImageView(frame: .zero)
    buttonLabel = UILabel(frame: .zero)
    super.init(frame: .zero)
    if let tag {
      self.tag = tag
    }
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    clipsToBounds = false
    isUserInteractionEnabled = true
    let size: CGFloat = {
      if operationMode == .arranging && buttonType == .keyboard {
        return 55
      }
      return 80
    }()
    widthAnchor.constraint(equalToConstant: size).isActive = true
    heightAnchor.constraint(equalTo: widthAnchor).isActive = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(imageView)
    imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    imageView.image = UIImage(named: buttonType.imageName)
    imageView.tintColor = .gray
    buttonLabel.text = buttonName
    buttonLabel.textColor = .gray
    buttonLabel.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    buttonLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(buttonLabel)
    buttonLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    buttonLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.gamepadButton(began: self, touches: touches, event: event)
    delegate?.gamepadButton(pressed: self, isMove: false)
    if operationMode == .normal {
      imageView.image = UIImage(named: "\(buttonType.imageName)-pressed")
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.gamepadButton(moved: self, touches: touches, event: event)
    delegate?.gamepadButton(pressed: self, isMove: true)
    if operationMode == .normal {
      imageView.image = UIImage(named: "\(buttonType.imageName)-pressed")
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("GamepadButtonView: touchesEnded!")
    delegate?.gamepadButton(released: self, touches: touches, event: event)
    if operationMode == .normal {
      imageView.image = UIImage(named: buttonType.imageName)
    }
  }
}
