//
//  AimControlsView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import UIKit

@objcMembers class MouseInputHolder: NSObject {
  static let shared = MouseInputHolder()
  var deltaX: Int = 0
  var deltaY: Int = 0
}

protocol AimControlsDelegate {
  func aimDidSingleTap()
  func aimDidDoubleTap()
  func aimDidMove(dx: Float, dy: Float, isDoubleTap: Bool)
  func aimEnded()
  func aimDidStart()
}

class AimControlsView: UIView {
  private var isDoubleTap = false
  private var isMoving = false
  private let timeToWaitAsecondTap: TimeInterval = 0.2
  private var startTouchPoint = CGPoint.zero
  
  var delegate: AimControlsDelegate?
  
  func singleTapAction() {
    if isDoubleTap || isMoving {
      return
    }
//    print(#function)
    delegate?.aimDidSingleTap()
  }
  
  func doubleTapAction() {
//    print(#function)
    delegate?.aimDidDoubleTap()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, touch.type == .direct else {
      return
    }
    print("AimControls touch type = \(touch.type)")
    delegate?.aimDidStart()
    startTouchPoint = touch.location(in: self)
    if touch.tapCount == 1 {
      DispatchQueue.main.asyncAfter(deadline: .now() + timeToWaitAsecondTap) {
        self.singleTapAction()    // always execute
      }
    } else if touch.tapCount == 2 {
      isDoubleTap = true  // not-always execute
      doubleTapAction()   // not-always execute
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, touch.type == .direct else { return }
    isMoving = true
    let location = touch.location(in: self)
    let prev = touch.previousLocation(in: self)
    let dx = location.x - prev.x
    let dy = location.y - prev.y
    delegate?.aimDidMove(dx: Float(dx), dy: Float(dy), isDoubleTap: isDoubleTap)
//    print("AIM touchesMoved: dx = \(dx), dy = \(dy), Tap type = \(isDoubleTap ? "DOUBLE TAP" : "NORMAL")")
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, touch.type == .direct else { return }
    isMoving = false
    isDoubleTap = false
    delegate?.aimEnded()
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, touch.type == .direct else { return }
    isMoving = false
    isDoubleTap = false
    delegate?.aimEnded()
  }
}
