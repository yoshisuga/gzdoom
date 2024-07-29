//
//  GamepadControlOptionsView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/28/24.
//

import SwiftUI

class ControlOptionsViewModel: ObservableObject, Codable {
  @Published var touchControlsOpacity: Float = 0.8
  @Published var aimSensitivity: Float = 1.0
  @Published var doubleTapForLeftClick = true
  @Published var doubleTapHoldForContinuousLeftClick = true
  @Published var touchControlHapticFeedback = true
  
  let userDefaultsKey = "controlOptions"
  
  enum CodingKeys: CodingKey {
    case touchControlsOpacity, aimSensitivity, doubleTapForLeftClick, doubleTapHoldForContinuousLeftClick, touchControlHapticFeedback
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(touchControlsOpacity, forKey: .touchControlsOpacity)
    try container.encode(aimSensitivity, forKey: .aimSensitivity)
    try container.encode(doubleTapForLeftClick, forKey: .doubleTapForLeftClick)
    try container.encode(doubleTapHoldForContinuousLeftClick, forKey: .doubleTapHoldForContinuousLeftClick)
    try container.encode(touchControlHapticFeedback, forKey: .touchControlHapticFeedback)
  }
  
  init() {}
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    touchControlsOpacity = try container.decode(Float.self, forKey: .touchControlsOpacity)
    aimSensitivity = try container.decode(Float.self, forKey: .aimSensitivity)
    doubleTapForLeftClick = try container.decode(Bool.self, forKey: .doubleTapForLeftClick)
    doubleTapHoldForContinuousLeftClick = try container.decode(Bool.self, forKey: .doubleTapHoldForContinuousLeftClick)
    touchControlHapticFeedback = try container.decode(Bool.self, forKey: .touchControlHapticFeedback)
  }
  
  func loadFromUserDefaults() {
    guard let saveData = UserDefaults.standard.data(forKey: userDefaultsKey),
          let saved = try? PropertyListDecoder().decode(ControlOptionsViewModel.self, from: saveData) else {
      return
    }
    touchControlsOpacity = saved.touchControlsOpacity
    aimSensitivity = saved.aimSensitivity
    doubleTapForLeftClick = saved.doubleTapForLeftClick
    doubleTapHoldForContinuousLeftClick = saved.doubleTapHoldForContinuousLeftClick
    touchControlHapticFeedback = saved.touchControlHapticFeedback
  }
  
  func saveToUserDefaults() {
    guard let data = try? PropertyListEncoder().encode(self) else {
      return
    }
    UserDefaults.standard.set(data, forKey: userDefaultsKey)
  }
}

struct OptionsSwitchRow: View {
  @Binding var isOn: Bool
  let label: String
  var subtitle: String?
  
  var body: some View {
    Toggle(isOn: $isOn) {
      if let subtitle {
        VStack {
          Text(label).font(.body).frame(maxWidth: .infinity, alignment: .leading)
          Text(subtitle).font(.small).frame(maxWidth: .infinity, alignment: .leading)
        }
      } else {
        Text(label).font(.body).frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}

struct OptionsSliderRow: View {
  @Binding var sliderValue: Float
  let label: String
  let min: Float
  let max: Float
  
  var body: some View {
    VStack {
      Text(label).font(.body).frame(maxWidth: .infinity, alignment: .leading)
      Slider(value: $sliderValue, in: min...max)
    }
  }
}

struct ControlOptionsView: View {
  @StateObject var viewModel: ControlOptionsViewModel
  
  var dismissClosure: (() -> Void)?
  
  init() {
    let model = ControlOptionsViewModel()
    model.loadFromUserDefaults()
    _viewModel = StateObject(wrappedValue: model)
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          Section (header: Text("General").font(.small)) {
            OptionsSliderRow(sliderValue: $viewModel.aimSensitivity, label: "Aim Sensitivity", min: 0.1, max: 1.0)
          }
          Section(header: Text("Touch Controls").font(.small)) {
            OptionsSliderRow(sliderValue: $viewModel.touchControlsOpacity, label: "Opacity", min: 0.1, max: 1.0)
            OptionsSwitchRow(isOn: $viewModel.doubleTapForLeftClick, label: "Double Tap for Left Click")
            OptionsSwitchRow(
              isOn: $viewModel.doubleTapHoldForContinuousLeftClick,
              label: "Double Tap and Hold for Continuous Left Click",
              subtitle: "Allows easier firing while moving and circle strafing."
            )
            OptionsSwitchRow(isOn: $viewModel.touchControlHapticFeedback, label: "Haptic Feedback")
          }
        }
        Button(action: {
          viewModel.saveToUserDefaults()
          dismissClosure?()
        }, label: {
          Text("Save")
        }).buttonStyle(.bordered).foregroundColor(.green).font(.actionButton)
      }.navigationTitle("Control Settings")
        .toolbar {
        Button(action: {
          dismissClosure?()
        }, label: {
          Text("Cancel")
        }).buttonStyle(.bordered).foregroundColor(.red).font(.actionButton)
      }
    }
  }
}
