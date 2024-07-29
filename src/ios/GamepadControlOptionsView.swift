//
//  GamepadControlOptionsView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/28/24.
//

import SwiftUI

class OptionsViewModel: ObservableObject {
  @Published var touchControlsOpacity: Float = 0.8
  @Published var aimSensitivity: Float = 1.0
  @Published var doubleTapForLeftClick = true
  @Published var doubleTapHoldForContinuousLeftClick = true
  @Published var touchControlHapticFeedback = true
}

struct GamepadControlOptionsView: View {
  var body: some View {
    NavigationView {
      Text("hello")
    }
  }
}
