//
//  GyroscopeHandler.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/31/24.
//

import Combine
import CoreMotion
import UIKit

class GyroscopeHandler {
  private let motionManager = CMMotionManager()
  private var deadZone: Double = 0.05 // Avoid small movements

  private var orientation: UIDeviceOrientation = .unknown
  private var cancellable: AnyCancellable?
  
  func setup() {
    guard motionManager.isGyroAvailable,
          !motionManager.isGyroActive,
          ControlOptionsViewModel.shared.gyroEnabled else {
      return
    }
    orientation = determineScreenOrientation()
    cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
      .sink(receiveValue: { [weak self] _ in
        guard let self else { return }
        self.orientation = self.determineScreenOrientation()
      })
    setupGyro()
  }
  
  func updateOrientation() {
    orientation = determineScreenOrientation()
  }
  
  private func determineScreenOrientation() -> UIDeviceOrientation {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first else {
      return .landscapeLeft
    }
    let fixedPoint = window.screen.coordinateSpace.convert(CGPoint.zero, to: window.screen.fixedCoordinateSpace)
    if fixedPoint.x == 0 {
      return .landscapeRight
    }
    return .landscapeLeft
  }
  
  private func setupGyro() {
    if motionManager.isGyroAvailable {
      motionManager.gyroUpdateInterval = 0.06 // Update interval (adjust as needed)
//      motionManager.gyroUpdateInterval = TimeInterval(ControlOptionsViewModel.shared.gyroUpdateInterval)

      motionManager.startGyroUpdates(to: .current!) { [weak self] (data, error) in
        guard let self else { return }
        guard ControlOptionsViewModel.shared.gyroEnabled else {
          self.motionManager.stopGyroUpdates()
          return
        }
        if let gyroData = data {
          self.handleGyroData(gyroData)
        }
      }
    } else {
      print("Gyroscope not available.")
    }
  }
  
  private func handleGyroData(_ gyroData: CMGyroData) {
    let xRotation = gyroData.rotationRate.x
    let yRotation = gyroData.rotationRate.y
    
    // Apply sensitivity and dead zone
    let sensitivity = Double(ControlOptionsViewModel.shared.gyroSensitivity)
    let orientationAdjustment: Double = orientation == .landscapeLeft ? 1 : -1;
//    let orientationAdjustment: Double = 1
    let adjustedX = abs(xRotation) > deadZone ? xRotation * sensitivity * -1 * orientationAdjustment : 0.0
    let adjustedY = abs(yRotation) > deadZone ? yRotation * sensitivity * orientationAdjustment : 0.0
    
    #if DEBUG
    print("gyro: \(adjustedX) , \(adjustedY), orientationAdjust: \(orientationAdjustment) orientation=\(orientation)")
    #endif
    MouseInputHolder.shared.gyroDeltaX = Int(adjustedX)
    MouseInputHolder.shared.gyroDeltaY = Int(adjustedY)
  }
}
