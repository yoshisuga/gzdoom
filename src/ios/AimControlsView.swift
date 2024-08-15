//
//  AimControlsView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import Combine
import UIKit

@objcMembers class MouseInputHolder: NSObject {
  static let shared = MouseInputHolder()
  var deltaX: Int = 0
  var deltaY: Int = 0
  
  var gyroDeltaX: Int = 0
  var gyroDeltaY: Int = 0
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
  private(set) var isMoving = false
  private let timeToWaitAsecondTap: TimeInterval = 0.2
  private var startTouchPoint = CGPoint.zero
  
  var delegate: AimControlsDelegate?
  
  private var touchSubject = PassthroughSubject<Void, Never>()
  private var cancellable: AnyCancellable?

  override init(frame: CGRect) {
      super.init(frame: frame)
      cancellable = touchSubject
      .debounce(for: .milliseconds(1), scheduler: RunLoop.main)
      .sink{ [weak self] in
        self?.delegate?.aimEnded()
      }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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
    touchSubject.send()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    print("AimControlsView: touchesEnded!")
    guard let touch = touches.first, touch.type == .direct else { return }
    isMoving = false
    isDoubleTap = false
    delegate?.aimEnded()
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//    print("AimControlsView: touchesCancelled!")
    guard let touch = touches.first, touch.type == .direct else { return }
    isMoving = false
    isDoubleTap = false
    delegate?.aimEnded()
  }
}
