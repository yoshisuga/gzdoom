//
//  GamepadControlOptionsView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/28/24.
//

import SwiftUI

class ControlOptionsViewModel: ObservableObject {
  @Published var touchControlsOpacity: Float = 0.8
  @Published var aimSensitivity: Float = 1.0
  @Published var doubleTapControl: OptionsDoubleTapControl = .none
  @Published var touchControlHapticFeedback = true
  @Published var controllerInvertYAxis = false
  @Published var gyroEnabled: Bool = true
  @Published var gyroSensitivity: Float = 5.0
  @Published var enableTouchControlsGuideOverlay: Bool = true
  
  let userDefaultsKey = "controlOptions"
  private static let userDefaultsKeyPrefix = "controlOptions_"
  
  enum OptionKeys: String {
    case touchControlsOpacity, aimSensitivity, doubleTapControl, touchControlHapticFeedback,
         controllerInvertYAxis
    case gyroEnabled, gyroSensitivity
    case enableTouchControlsGuideOverlay
    
    var keyName: String {
      return "\(userDefaultsKeyPrefix)\(self.rawValue)"
    }
  }
  
  private init() {
    loadFromUserDefaults()
  }
  
  static let shared = ControlOptionsViewModel()
  
  func loadFromUserDefaults() {
    if let touchOpacity = UserDefaults.standard.object(forKey: OptionKeys.touchControlsOpacity.keyName) as? Float {
      touchControlsOpacity = touchOpacity
    } else {
      touchControlsOpacity = 0.8
    }
    
    if let aimSensitivityDef = UserDefaults.standard.object(forKey: OptionKeys.aimSensitivity.keyName) as? Float {
      aimSensitivity = aimSensitivityDef
    } else {
      aimSensitivity = 1.0
    }
    
    if let doubleTapControlDef = UserDefaults.standard.object(forKey: OptionKeys.doubleTapControl.keyName) as? Int,
       let doubleTapLookup = OptionsDoubleTapControl(rawValue: doubleTapControlDef)
    {
      doubleTapControl = doubleTapLookup
    } else {
      doubleTapControl = .none
    }
    
    if let touchControlHapticFeedbackDef = UserDefaults.standard.object(forKey: OptionKeys.touchControlHapticFeedback.keyName) as? Bool {
      touchControlHapticFeedback = touchControlHapticFeedbackDef
    } else {
      touchControlHapticFeedback = true
    }
    
    if let controllerInvertYAxisDef = UserDefaults.standard.object(forKey: OptionKeys.controllerInvertYAxis.keyName) as? Bool {
      controllerInvertYAxis = controllerInvertYAxisDef
    } else {
      controllerInvertYAxis = false
    }
    
    if let gyroEnabledDef = UserDefaults.standard.object(forKey: OptionKeys.gyroEnabled.keyName) as? Bool {
      gyroEnabled = gyroEnabledDef
    } else {
      gyroEnabled = true
    }
    
    if let gyroSensitivityDef = UserDefaults.standard.object(forKey: OptionKeys.gyroSensitivity.keyName) as? Float {
      gyroSensitivity = gyroSensitivityDef
    } else {
      gyroSensitivity = 5.0
    }
    
    if let touchControlsGuideOverlayDef = UserDefaults.standard.object(forKey: OptionKeys.enableTouchControlsGuideOverlay.keyName) as? Bool {
      enableTouchControlsGuideOverlay = touchControlsGuideOverlayDef
    } else {
      enableTouchControlsGuideOverlay = true
    }
  }
  
  func saveToUserDefaults() {
    UserDefaults.standard.set(touchControlsOpacity, forKey: OptionKeys.touchControlsOpacity.keyName)
    UserDefaults.standard.set(aimSensitivity, forKey: OptionKeys.aimSensitivity.keyName)
    UserDefaults.standard.set(doubleTapControl.rawValue, forKey: OptionKeys.doubleTapControl.keyName)
    UserDefaults.standard.set(touchControlHapticFeedback, forKey: OptionKeys.touchControlHapticFeedback.keyName)
    UserDefaults.standard.set(controllerInvertYAxis, forKey: OptionKeys.controllerInvertYAxis.keyName)
    UserDefaults.standard.set(gyroEnabled, forKey: OptionKeys.gyroEnabled.keyName)
    UserDefaults.standard.set(gyroSensitivity, forKey: OptionKeys.gyroSensitivity.keyName)
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
            OptionsSwitchRow(isOn: $viewModel.enableTouchControlsGuideOverlay, label: "Show Move/Aim Overlay Guide")
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
