//
//  JoystickView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import UIKit

@objcMembers class JoystickInputHolder: NSObject {
  static let shared = JoystickInputHolder()
  var axisX: Float = 0
  var axisY: Float = 0
  
  var buttonState: UInt8 = 0
}

protocol JoystickDelegate {
  func joystickMoved(dx: Float, dy: Float)
  func joystickEnded()
  func joystickDidStart()
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
    guard let touch = touches.first, touch.type == .direct else { return }
    delegate?.joystickDidStart()
    joystickCenter = touch.location(in: self)
    knobCenter = joystickCenter
    isTouching = true
    setNeedsDisplay()
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, touch.type == .direct else { return }
    let location = touch.location(in: self)
    let deadzone = CGFloat(ControlOptionsViewModel.shared.touchJoystickDeadzone)
    let dx = abs(location.x - joystickCenter.x) > deadzone ? location.x - joystickCenter.x : 0.0
    let dy = abs(location.y - joystickCenter.y) > deadzone ? location.y - joystickCenter.y : 0.0
    // Yoshi temp: disabling for now to test new joystick impl
//    delegate?.joystickMoved(dx: Float(dx), dy: Float(dy))
    print("touchesMoved: dx = \(dx), dy = \(dy)")
    let distance = sqrt(dx * dx + dy * dy)
    let maxDistance: CGFloat = 50

    let angle = atan2(dy, dx)
    if distance > maxDistance {
      knobCenter = CGPoint(x: joystickCenter.x + cos(angle) * maxDistance, y: joystickCenter.y + sin(angle) * maxDistance)
    } else {
      knobCenter = location
    }
    
//    let knobPosition = CGPoint(x: cos(angle) * 50, y: sin(angle) * 50)
    let normalizedX = dx / 50
    let normalizedY = dy / 50
    let clampedX = max(-1, min(1, normalizedX))
    let clampedY = max(-1, min(1, normalizedY))
    #if DEBUG
    print("JoystickView: knobpos=\(knobCenter), norm=\(normalizedX),\(normalizedY) x=\(clampedX),y=\(clampedY)")
    #endif
    JoystickInputHolder.shared.axisX = Float(clampedX)
    JoystickInputHolder.shared.axisY = Float(clampedY)
    
    setNeedsDisplay()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, touch.type == .direct else { return }
    isTouching = false
    setNeedsDisplay()
    delegate?.joystickEnded()
    
    JoystickInputHolder.shared.axisX = 0
    JoystickInputHolder.shared.axisY = 0
  }
  
  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    
    if isTouching {
      // Draw the joystick base
      context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
      context.addArc(center: joystickCenter, radius: 50, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
      context.fillPath()
      
      // Draw the knob
      context.setFillColor(UIColor.gray.cgColor)
      context.addArc(center: knobCenter, radius: 20, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
      context.fillPath()
    }
  }
}
