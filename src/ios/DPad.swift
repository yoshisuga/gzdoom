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
    }
  }
}

protocol DPadDelegate: AnyObject {
  func dPad(_ dPadView: DPadView, didPress: DPadDirection)
  func dPadDidRelease(_ dPadView: DPadView)
}

class DPadView: UIView {
  let imageView: UIImageView
  var currentDirection: DPadDirection = .none
  
  weak var delegate: DPadDelegate?
  
  init() {
    imageView = UIImageView(frame: .zero)
    imageView.translatesAutoresizingMaskIntoConstraints = false
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
    imageView.tintColor = .white
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
      imageView.image = currentDirection.image
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
      imageView.image = currentDirection.image
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    currentDirection = .none
    delegate?.dPadDidRelease(self)
    imageView.image = currentDirection.image
  }
}
