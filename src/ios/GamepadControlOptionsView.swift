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
  @Published var doubleTapControl: OptionsDoubleTapControl = .none
  @Published var touchControlHapticFeedback = true
  @Published var controllerInvertYAxis = false
  @Published var gyroEnabled: Bool = true
  @Published var gyroSensitivity: Float = 5.0
  
  let userDefaultsKey = "controlOptions"
  
  enum CodingKeys: CodingKey {
    case touchControlsOpacity, aimSensitivity, doubleTapControl, touchControlHapticFeedback,
         controllerInvertYAxis
    case gyroEnabled, gyroSensitivity
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(touchControlsOpacity, forKey: .touchControlsOpacity)
    try container.encode(aimSensitivity, forKey: .aimSensitivity)
    try container.encode(doubleTapControl.rawValue, forKey: .doubleTapControl)
    try container.encode(touchControlHapticFeedback, forKey: .touchControlHapticFeedback)
    try container.encode(controllerInvertYAxis, forKey: .controllerInvertYAxis)
    try container.encode(gyroEnabled, forKey: .gyroEnabled)
    try container.encode(gyroSensitivity, forKey: .gyroSensitivity)
  }
  
  private init() {
    loadFromUserDefaults()
  }
  
  static let shared = ControlOptionsViewModel()
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    touchControlsOpacity = try container.decode(Float.self, forKey: .touchControlsOpacity)
    aimSensitivity = try container.decode(Float.self, forKey: .aimSensitivity)
    doubleTapControl = try container.decode(OptionsDoubleTapControl.self, forKey: .doubleTapControl)
    touchControlHapticFeedback = try container.decode(Bool.self, forKey: .touchControlHapticFeedback)
    controllerInvertYAxis = try container.decode(Bool.self, forKey: .controllerInvertYAxis)
    gyroEnabled = try container.decode(Bool?.self, forKey: .gyroEnabled) ?? false
    gyroSensitivity = try container.decode(Float?.self, forKey: .gyroSensitivity) ?? 1.0
  }
  
  func loadFromUserDefaults() {
    guard let saveData = UserDefaults.standard.data(forKey: userDefaultsKey),
          let saved = try? PropertyListDecoder().decode(ControlOptionsViewModel.self, from: saveData) else {
      return
    }
    touchControlsOpacity = saved.touchControlsOpacity
    aimSensitivity = saved.aimSensitivity
    doubleTapControl = saved.doubleTapControl
    touchControlHapticFeedback = saved.touchControlHapticFeedback
    controllerInvertYAxis = saved.controllerInvertYAxis
    gyroEnabled = saved.gyroEnabled
    gyroSensitivity = saved.gyroSensitivity
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
          Text(label).font(.body).frame(maxWidth: .infinity, alignment: .leading).padding()
          Text(subtitle).font(.small).frame(maxWidth: .infinity, alignment: .leading).padding()
        }
      } else {
        Text(label).font(.body).frame(maxWidth: .infinity, alignment: .leading).padding()
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
      Text(label).font(.body).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
      Slider(value: $sliderValue, in: min...max).padding().tint(.red)
    }
  }
}

enum OptionsDoubleTapControl: Int, CaseIterable, Identifiable, Codable {
  case none, RT, LT, leftMouseButton, rightMouseButton
  var id: Self { self }

  var gameControl: GamepadControl? {
    switch self {
    case .RT: return .RT
    case .LT: return .LT
    case .leftMouseButton: return .leftMouseClick
    case .rightMouseButton: return .rightMouseClick
    default: return nil
    }
  }
}

struct OptionsDoubleTapPickerRow: View {
  @Binding var selectedControl: OptionsDoubleTapControl
  
  var body: some View {
    Picker(selection: $selectedControl) {
      ForEach(OptionsDoubleTapControl.allCases) { option in
        if let gameControl = option.gameControl {
          Text(gameControl.name).font(.body)
        } else if option == .none {
          Text("None").font(.body)
        }
      }
    } label: {
      VStack {
        Text("Double tap and hold on aiming will continually press:").font(.body).frame(maxWidth: .infinity, alignment: .leading).padding()
        Text("Allows easier firing while moving and circle strafing.").font(.small).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
      }
    }
  }
}

struct ControlOptionsView: View {
  @StateObject var viewModel: ControlOptionsViewModel
  
  var dismissClosure: (() -> Void)?
  
  init() {
    let model = ControlOptionsViewModel.shared
    model.loadFromUserDefaults()
    _viewModel = StateObject(wrappedValue: model)
    UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "PerfectDOSVGA437", size: 20)!]
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          Section (header: Text("General").font(.small)) {
            OptionsSliderRow(sliderValue: $viewModel.aimSensitivity, label: "Aim Sensitivity", min: 0.25, max: 4.0)
          }
          Section(header: Text("Touch Controls").font(.small)) {
            OptionsSliderRow(sliderValue: $viewModel.touchControlsOpacity, label: "Opacity", min: 0.1, max: 1.0)
            OptionsDoubleTapPickerRow(selectedControl: $viewModel.doubleTapControl)
            OptionsSwitchRow(isOn: $viewModel.touchControlHapticFeedback, label: "Haptic Feedback")
          }
          Section(header: Text("Gyroscope").font(.small)) {
            OptionsSwitchRow(isOn: $viewModel.gyroEnabled, label: "Gyroscope Aiming")
            OptionsSliderRow(sliderValue: $viewModel.gyroSensitivity, label: "Gyroscope Sensitivity", min: 2, max: 10.0)
          }
          Section(header: Text("Game Controller").font(.small)) {
            OptionsSwitchRow(isOn: $viewModel.controllerInvertYAxis, label: "Invert Y-Axis for Aiming/Right Stick")
          }
        }
      }.navigationTitle("Control Settings").navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button(action: {
              viewModel.aimSensitivity = 1.0
              viewModel.touchControlsOpacity = 0.8
              viewModel.doubleTapControl = .none
              viewModel.touchControlHapticFeedback = true
              viewModel.saveToUserDefaults()
              dismissClosure?()
            }, label: {
              Text("Reset")
            }).buttonStyle(.bordered).foregroundColor(.white).font(.actionButton)
          }

          ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
              viewModel.saveToUserDefaults()
              dismissClosure?()
            }, label: {
              Text("Save")
            }).buttonStyle(.bordered).foregroundColor(.green).font(.actionButton)
          }

          ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
              dismissClosure?()
            }, label: {
              Text("Cancel")
            }).buttonStyle(.bordered).foregroundColor(.red).font(.actionButton)
          }
      }
    }
  }
}
