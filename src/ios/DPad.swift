//
//  DPad.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 6/4/24.
//

import Foundation
import UIKit

extension DPadDirection  {
  var image: UIImage {
    switch self {
    case .upLeft:
      return UIImage(named: "dPad-UpLeft")!
    case .up:
      return UIImage(named: "dPad-Up")!
    case .upRight:
      return UIImage(named: "dPad-UpRight")!
    case .left:
      return UIImage(named: "dPad-Left")!
    case .none:
      return UIImage(named: "dPad-None")!
    case .right:
      return UIImage(named: "dPad-Right")!
    case .downLeft:
      return UIImage(named: "dPad-DownLeft")!
    case .down:
      return UIImage(named: "dPad-Down")!
    case .downRight:
      return UIImage(named: "dPad-DownRight")!
    default:
      return UIImage(named: "dPad-None")!
    }
  }
}

protocol DPadDelegate: AnyObject {
  func dPad(_ dPadView: DPadView, didPress: DPadDirection)
  func dPadDidRelease(_ dPadView: DPadView)
  func dPad(colorCustomized dPadView: DPadView)
}

extension DPadDelegate {
  func dPad(colorCustomized dPadView: DPadView) {}
}

class DPadView: UIView, CustomizableColor {
  let imageView: UIImageView
  var currentDirection: DPadDirection = .none
  
  weak var delegate: DPadDelegate?
  
  var isAnimated = true

  var customizedColor: UIColor? {
    didSet {
      let colorToSet = customizedColor ?? .gray
      imageView.tintColor = colorToSet
    }
  }

  let colorCustomizeButton: UIButton = {
    let button = UIButton(type: .custom)
    let config = UIImage.SymbolConfiguration.preferringMulticolor()
    let image = UIImage(systemName: "paintpalette")
    button.setImage(image?.applyingSymbolConfiguration(config), for: .normal)
    button.isHidden = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.widthAnchor.constraint(equalToConstant: 20).isActive = true
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

  init(customizedColor: UIColor? = nil) {
    imageView = UIImageView(frame: .zero)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    self.customizedColor = customizedColor
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    clipsToBounds = false
    isUserInteractionEnabled = true
    addSubview(imageView)
    let constraints = [
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ]
    NSLayoutConstraint.activate(constraints)
    imageView.image = UIImage(named: "dPad-None")
    imageView.tintColor = self.customizedColor ?? .gray
    addSubview(colorCustomizeButton)
    colorCustomizeButton.trailingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
    colorCustomizeButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    colorCustomizeButton.addTarget(self, action: #selector(colorCustomizeButtonPressed(_:)), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func direction(for point: CGPoint) -> DPadDirection {
    let x = point.x
    let y = point.y
    if x <= 0 || x >= self.bounds.size.width || y <= 0 || y >= self.bounds.size.height {
      return .none
    }
    let column = Int(x / (self.bounds.size.width / 3))
    let row = Int(y / (self.bounds.size.height / 3))
    let direction = DPadDirection(rawValue: (row * 3) + column)
    return direction ?? .none
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let point = touch.location(in: self)
    let direction = direction(for: point)
    if direction != currentDirection {
      currentDirection = direction
      delegate?.dPad(self, didPress: currentDirection)
      if isAnimated {
        imageView.image = currentDirection.image
      }
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let point = touch.location(in: self)
    let direction = direction(for: point)
    if direction != currentDirection {
      currentDirection = direction
      delegate?.dPad(self, didPress: currentDirection)
      if isAnimated {
        imageView.image = currentDirection.image
      }
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    currentDirection = .none
    delegate?.dPadDidRelease(self)
    if isAnimated {
      imageView.image = currentDirection.image
    } else {
      colorCustomizeButton.isHidden.toggle()
    }
  }
  
  @objc private func colorCustomizeButtonPressed(_ sender: UIButton) {
    delegate?.dPad(colorCustomized: self)
  }

  // Since the arrange-specific buttons are outside of the bounds, allow touches to them
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // Convert point to color button coordinate system
    let pointForCustomizeColorButton = colorCustomizeButton.convert(point, from: self)
    if CGRectContainsPoint(colorCustomizeButton.bounds, pointForCustomizeColorButton) {
      return colorCustomizeButton.hitTest(pointForCustomizeColorButton, with: event)
    }
    return super.hitTest(point, with: event)
  }
}
