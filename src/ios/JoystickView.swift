//
//  JoystickView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import UIKit

protocol JoystickDelegate {
  func joystickMoved(dx: Float, dy: Float)
  func joystickEnded()
}

class JoystickView: UIView {
  private var joystickCenter: CGPoint = .zero
  private var knobCenter: CGPoint = .zero
  private var isTouching: Bool = false
  
  var delegate: JoystickDelegate?
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    backgroundColor = .clear
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    joystickCenter = touch.location(in: self)
    knobCenter = joystickCenter
    isTouching = true
    setNeedsDisplay()
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    let dx = location.x - joystickCenter.x
    let dy = location.y - joystickCenter.y
    delegate?.joystickMoved(dx: Float(dx), dy: Float(dy))
    print("touchesMoved: dx = \(dx), dy = \(dy)")
    let distance = sqrt(dx * dx + dy * dy)
    let maxDistance: CGFloat = 50
    
    if distance > maxDistance {
      let angle = atan2(dy, dx)
      knobCenter = CGPoint(x: joystickCenter.x + cos(angle) * maxDistance, y: joystickCenter.y + sin(angle) * maxDistance)
    } else {
      knobCenter = location
    }
    setNeedsDisplay()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    isTouching = false
    setNeedsDisplay()
    delegate?.joystickEnded()
  }
  
  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    
    if isTouching {
      // Draw the joystick base
      context.setFillColor(UIColor.red.withAlphaComponent(0.5).cgColor)
      context.addArc(center: joystickCenter, radius: 50, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
      context.fillPath()
      
      // Draw the knob
      context.setFillColor(UIColor.blue.cgColor)
      context.addArc(center: knobCenter, radius: 20, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
      context.fillPath()
    }
  }
}
