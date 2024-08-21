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
  func gamepadButton(customizeColorPressed button: GamepadButtonView)
}

extension GamepadButtonDelegate {
  func gamepadButton(began button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {}
  func gamepadButton(moved button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {}
  func gamepadButton(customizeColorPressed button: GamepadButtonView) {}
}

protocol CustomizableColor {
  var customizedColor: UIColor? { get set }
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
  case normal, arranging, adding
}

enum GamepadButtonSize: CGFloat, CaseIterable {
  case small = 50, medium = 80, large = 120
  
  static let userDefaultsKey = "buttonSizes"
  
  func next() -> GamepadButtonSize {
    let allCases = GamepadButtonSize.allCases
    if let currentIndex = allCases.firstIndex(of: self) {
      let nextIndex = allCases.index(after: currentIndex)
      return nextIndex < allCases.endIndex ? allCases[nextIndex] : allCases.first!
    }
    return allCases.first!
  }
}

class GamepadButtonView: AlignableView, CustomizableColor {
  let imageView: UIImageView
  private let buttonLabel: UILabel
  
  let colorCustomizeButton: UIButton = {
    let button = UIButton(type: .custom)
    let config = UIImage.SymbolConfiguration.preferringMulticolor()
    let image = UIImage(systemName: "paintpalette")
    button.setImage(image?.applyingSymbolConfiguration(config), for: .normal)
    button.isHidden = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.widthAnchor.constraint(equalToConstant: 30).isActive = true
    button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    let pulse = CABasicAnimation(keyPath: "transform.scale")
    pulse.duration = 0.5
    pulse.fromValue = 0.8
    pulse.toValue = 1.3
    pulse.autoreverses = true
    pulse.repeatCount = .greatestFiniteMagnitude
    button.imageView?.layer.add(pulse, forKey: "pulse")
    return button
  }()
  
  let sizeCustomizeButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "arrow.up.right.and.arrow.down.left.rectangle"), for: .normal)
    button.isHidden = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.widthAnchor.constraint(equalToConstant: 30).isActive = true
    button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    button.imageView?.tintColor = .red
    let pulse = CABasicAnimation(keyPath: "transform.scale")
    pulse.duration = 0.5
    pulse.fromValue = 0.8
    pulse.toValue = 1.3
    pulse.autoreverses = true
    pulse.repeatCount = .greatestFiniteMagnitude
    button.imageView?.layer.add(pulse, forKey: "pulse")
    return button
  }()
  
  let buttonName: String
  let buttonType: GamepadButtonType
  var operationMode: GamepadButtonTypeOperationMode

  var customizedColor: UIColor? {
    didSet {
      let colorToSet = customizedColor ?? .gray
      imageView.tintColor = colorToSet
      buttonLabel.textColor = colorToSet
    }
  }
  
  var buttonSize: GamepadButtonSize = .medium {
    didSet {
      if translatesAutoresizingMaskIntoConstraints {
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        let newSize = CGSize(width: buttonSize.rawValue, height: buttonSize.rawValue)
        let existingCenter = center
        frame.size = newSize
        center = existingCenter
//        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: buttonSize.rawValue, height: buttonSize.rawValue)
      }
    }
  }
  var widthConstraint: NSLayoutConstraint?
  var heightConstraint: NSLayoutConstraint?
  
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
    tag: Int? = nil,
    customizedColor: UIColor? = nil,
    buttonSize: GamepadButtonSize? = .medium
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
    self.customizedColor = customizedColor
    self.buttonSize = buttonSize!
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
      if operationMode == .adding && buttonType == .keyboard {
        return 55
      }
      return buttonSize.rawValue
    }()
    widthConstraint = widthAnchor.constraint(equalToConstant: size)
    widthConstraint?.isActive = true
    heightAnchor.constraint(equalTo: widthAnchor).isActive = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(imageView)
    imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    imageView.image = UIImage(named: buttonType.imageName)
    imageView.tintColor = customizedColor ?? .gray
    buttonLabel.text = buttonName
    buttonLabel.textColor = customizedColor ?? .gray
    buttonLabel.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    if buttonName.starts(with: "SFMONO_"),
       let specialPart = buttonName.split(separator: "_")[safe: 1] {
      buttonLabel.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .bold)
      let text: String = {
        switch specialPart {
        case "UP": return "↑"
        case "DOWN": return "↓"
        case "LEFT": return "←"
        case "RIGHT": return "→"
        default: return "↑"
        }
      }()
      buttonLabel.text = text
    }
    buttonLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(buttonLabel)
    buttonLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    buttonLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    addSubview(colorCustomizeButton)
    colorCustomizeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -8).isActive = true
    colorCustomizeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    colorCustomizeButton.addTarget(self, action: #selector(colorCustomizeButtonPressed(_:)), for: .touchUpInside)
    addSubview(sizeCustomizeButton)
    sizeCustomizeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8).isActive = true
    sizeCustomizeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    sizeCustomizeButton.addTarget(self, action: #selector(sizeCustomizeButtonPressed(_:)), for: .touchUpInside)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.gamepadButton(began: self, touches: touches, event: event)
    delegate?.gamepadButton(pressed: self, isMove: false)
    if operationMode == .normal {
      setPressedState()
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.gamepadButton(moved: self, touches: touches, event: event)
    delegate?.gamepadButton(pressed: self, isMove: true)
    if operationMode == .normal {
      setPressedState()
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("GamepadButtonView: touchesEnded!")
    delegate?.gamepadButton(released: self, touches: touches, event: event)
    setNormalState()
    if operationMode == .arranging {
      colorCustomizeButton.isHidden.toggle()
      sizeCustomizeButton.isHidden.toggle()
    }
  }
  
  func setNormalState() {
    imageView.image = UIImage(named: buttonType.imageName)
  }
  
  func setPressedState() {
    imageView.image = UIImage(named: "\(buttonType.imageName)-pressed")
  }
  
  @objc private func colorCustomizeButtonPressed(_ sender: UIButton) {
    delegate?.gamepadButton(customizeColorPressed: self)
  }
  
  @objc private func sizeCustomizeButtonPressed(_ sender: UIButton) {
    buttonSize = buttonSize.next()
  }
  
  // Since the arrange-specific buttons are outside of the bounds, allow touches to them
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // Convert point to color button coordinate system
    let pointForCustomizeColorButton = colorCustomizeButton.convert(point, from: self)
    if CGRectContainsPoint(colorCustomizeButton.bounds, pointForCustomizeColorButton) {
      return colorCustomizeButton.hitTest(pointForCustomizeColorButton, with: event)
    }
    let pointForCustomizeSizeButton = sizeCustomizeButton.convert(point, from: self)
    if CGRectContainsPoint(sizeCustomizeButton.bounds, pointForCustomizeSizeButton) {
      return sizeCustomizeButton.hitTest(pointForCustomizeSizeButton, with: event)
    }
    return super.hitTest(point, with: event)
  }
  
}
