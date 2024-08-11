//
//  GyroscopeHandler.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/31/24.
//

import CoreMotion
import UIKit

class GyroscopeHandler {
  private let motionManager = CMMotionManager()
  private var deadZone: Double = 0.05 // Avoid small movements

  func setup() {
    guard motionManager.isGyroAvailable,
          !motionManager.isGyroActive,
          ControlOptionsViewModel.shared.gyroEnabled else {
      return
    }
    setupGyro()
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
    let orientationAdjustment: Double = UIDevice.current.orientation == .landscapeLeft ? 1 : -1;
    let adjustedX = abs(xRotation) > deadZone ? xRotation * sensitivity * -1 * orientationAdjustment : 0.0
    let adjustedY = abs(yRotation) > deadZone ? yRotation * sensitivity * orientationAdjustment : 0.0
    
//    print("\(adjustedX) , \(adjustedY)")
    MouseInputHolder.shared.gyroDeltaX = Int(adjustedX)
    MouseInputHolder.shared.gyroDeltaY = Int(adjustedY)
  }
}
