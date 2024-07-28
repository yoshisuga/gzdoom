//
//  GamepadButtonView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 6/4/24.
//

import Foundation
import UIKit

protocol GamepadButtonDelegate: AnyObject {
  func gamepadButton(pressed button: GamepadButtonView);
  func gamepadButton(released button: GamepadButtonView);
}

class GamepadButtonView: UIView {
  let imageView: UIImageView
  private let buttonLabel: UILabel
  
  let buttonName: String
  
  weak var delegate: GamepadButtonDelegate?
  
  init(buttonName: String) {
    self.buttonName = buttonName
    imageView = UIImageView(frame: .zero)
    buttonLabel = UILabel(frame: .zero)
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    clipsToBounds = false
    isUserInteractionEnabled = true
    widthAnchor.constraint(equalToConstant: 50.0).isActive = true
    heightAnchor.constraint(equalTo: widthAnchor).isActive = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(imageView)
    imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    imageView.image = UIImage(named: "button")
    imageView.tintColor = .gray
    buttonLabel.text = buttonName
    buttonLabel.textColor = .gray
    buttonLabel.font = UIFont.systemFont(ofSize: 9.0, weight: .bold)
    buttonLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(buttonLabel)
    buttonLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    buttonLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.gamepadButton(pressed: self)
    imageView.image = UIImage(named: "button-pressed")
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.gamepadButton(pressed: self)
    imageView.image = UIImage(named: "button-pressed")
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.gamepadButton(released: self)
    imageView.image = UIImage(named: "button")
  }
}
