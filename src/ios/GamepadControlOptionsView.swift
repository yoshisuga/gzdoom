//
//  GamepadControlOptionsView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/28/24.
//

import SwiftUI

@objcMembers class ObjCControlOptionsViewModel: NSObject {
  static var aimSensitivity: Float {
    ControlOptionsViewModel.shared.aimSensitivity
  }
}

class ControlOptionsViewModel: ObservableObject {
  @Published var touchControlsOpacity: Float = 0.8
  @Published var aimSensitivity: Float = 1.4
  @Published var touchControlHapticFeedback = true
  @Published var controllerInvertYAxis = false
  @Published var gyroEnabled: Bool = true
  @Published var gyroSensitivity: Float = 5.0
  @Published var gyroUpdateInterval: Float = 0.06
  @Published var enableTouchControlsGuideOverlay: Bool = true
  @Published var touchJoystickDeadzone: Float = 10
  
  let userDefaultsKey = "controlOptions"
  private static let userDefaultsKeyPrefix = "controlOptions_"
  
  enum OptionKeys: String {
    case touchControlsOpacity, aimSensitivity, touchControlHapticFeedback,
         controllerInvertYAxis
    case gyroEnabled, gyroSensitivity, gyroUpdateInterval
    case enableTouchControlsGuideOverlay
    case touchJoystickDeadzone
    
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
      aimSensitivity = 1.4
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

    if let gyroUpdateDef = UserDefaults.standard.object(forKey: OptionKeys.gyroUpdateInterval.keyName) as? Float {
      gyroUpdateInterval = gyroUpdateDef
    } else {
      gyroUpdateInterval = 0.06
    }

    if let touchControlsGuideOverlayDef = UserDefaults.standard.object(forKey: OptionKeys.enableTouchControlsGuideOverlay.keyName) as? Bool {
      enableTouchControlsGuideOverlay = touchControlsGuideOverlayDef
    } else {
      enableTouchControlsGuideOverlay = true
    }
    
    if let joystickDeadzoneDef = UserDefaults.standard.object(forKey: OptionKeys.touchJoystickDeadzone.keyName) as? Float {
      touchJoystickDeadzone = joystickDeadzoneDef
    } else {
      touchJoystickDeadzone = 10
    }
  }
  
  func saveToUserDefaults() {
    UserDefaults.standard.set(touchControlsOpacity, forKey: OptionKeys.touchControlsOpacity.keyName)
    UserDefaults.standard.set(aimSensitivity, forKey: OptionKeys.aimSensitivity.keyName)
    UserDefaults.standard.set(touchControlHapticFeedback, forKey: OptionKeys.touchControlHapticFeedback.keyName)
    UserDefaults.standard.set(controllerInvertYAxis, forKey: OptionKeys.controllerInvertYAxis.keyName)
    UserDefaults.standard.set(gyroEnabled, forKey: OptionKeys.gyroEnabled.keyName)
    UserDefaults.standard.set(gyroSensitivity, forKey: OptionKeys.gyroSensitivity.keyName)
    UserDefaults.standard.set(gyroUpdateInterval, forKey: OptionKeys.gyroUpdateInterval.keyName)
    UserDefaults.standard.set(touchJoystickDeadzone, forKey: OptionKeys.touchJoystickDeadzone.keyName)
    UserDefaults.standard.set(enableTouchControlsGuideOverlay, forKey: OptionKeys.enableTouchControlsGuideOverlay.keyName)
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
      #if os(iOS)
      Slider(value: $sliderValue, in: min...max).padding().tint(.red)
      #else
      TvOSSliderSwiftUI(value: $sliderValue, minimumValue: min, maximumValue: max)
      #endif
      #if DEBUG
      Text("\(sliderValue)").font(.small)
      #endif
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

struct NavigationWrapper<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
        }
    }
}

struct ControlOptionsView: View {
  @StateObject var viewModel: ControlOptionsViewModel
  
  var dismissClosure: (() -> Void)?
  
  @State private var selectedAppIcon: String? = UIApplication.shared.alternateIconName
  
  init(dismissClosure: (() -> Void)? = nil) {
    self.dismissClosure = dismissClosure
    let model = ControlOptionsViewModel.shared
    model.loadFromUserDefaults()
    _viewModel = StateObject(wrappedValue: model)
    UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "PerfectDOSVGA437", size: 20)!]
  }
  
  private func changeAppIcon(to iconName: String?) {
    guard UIApplication.shared.supportsAlternateIcons else { return }
    UIApplication.shared.setAlternateIconName(iconName) { error in
      if let error = error {
        print("Error changing app icon: \(error.localizedDescription)")
      } else {
        selectedAppIcon = iconName
      }
    }
  }
  
  private var appIconSection: some View {
    Section(header: Text("App Icon").font(.small)) {
      HStack {
        Spacer()
        VStack {
          #if ZERO
          Image("OptionSettingIconZero")
            .resizable()
            .frame(width: 50, height: 50)
          #else
          Image("OptionSettingIconModern")
            .resizable()
            .frame(width: 50, height: 50)
          #endif
          #if ZERO
          Text("Zero").font(.small)
          #else
          Text("Modern").font(.small)
          #endif
          if selectedAppIcon == nil {
            Image(systemName: "checkmark.circle.fill")
          } else {
            Image(systemName: "circle")
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          changeAppIcon(to: nil)
        }
        Spacer()
        VStack {
          Image("OptionSettingIconClassic")
            .resizable()
            .frame(width: 50, height: 50)
          Text("Classic").font(.small)
          if selectedAppIcon == "AppIcon" {
            Image(systemName: "checkmark.circle.fill")
          } else {
            Image(systemName: "circle")
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          changeAppIcon(to: "AppIcon")
        }
        Spacer()
        #if ZERO
        VStack {
          Image("OptionSettingIconModern")
            .resizable()
            .frame(width: 50, height: 50)
          Text("Modern").font(.small)
          if selectedAppIcon == "AppIcon18" {
            Image(systemName: "checkmark.circle.fill")
          } else {
            Image(systemName: "circle")
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          changeAppIcon(to: "AppIcon18")
        }
        #else
        VStack {
          Image("OptionSettingIconZero")
            .resizable()
            .frame(width: 50, height: 50)
          Text("Zero").font(.small)
          if selectedAppIcon == "AppIconZero" {
            Image(systemName: "checkmark.circle.fill")
          } else {
            Image(systemName: "circle")
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          changeAppIcon(to: "AppIconZero")
        }
        #endif
        Spacer()
      }
    }
  }
  
  var body: some View {
    
    NavigationWrapper {
      VStack {
        List {
          Section (header: Text("General").font(.small)) {
            OptionsSliderRow(sliderValue: $viewModel.aimSensitivity, label: "Aim Sensitivity", min: 0.25, max: 4.0)
#if !os(tvOS)
            OptionsSwitchRow(isOn: $viewModel.enableTouchControlsGuideOverlay, label: "Show Move/Aim Overlay Guide")
#endif
          }
#if !os(tvOS)
          Section(header: Text("Touch Controls").font(.small)) {
            OptionsSwitchRow(isOn: $viewModel.touchControlHapticFeedback, label: "Haptic Feedback")
            OptionsSliderRow(sliderValue: $viewModel.touchJoystickDeadzone, label: "Movement Joystick Deadzone", min: 0, max: 40.0)
          }
          Section(header: Text("Gyroscope").font(.small)) {
            OptionsSwitchRow(isOn: $viewModel.gyroEnabled, label: "Gyroscope Aiming")
            OptionsSliderRow(sliderValue: $viewModel.gyroSensitivity, label: "Gyroscope Sensitivity", min: 2, max: 10.0)
            #if DEBUG
            OptionsSliderRow(sliderValue: $viewModel.gyroUpdateInterval, label: "Gyroscope Update Interval", min: 0.0167, max: 1.0)
            #endif
          }
#endif
          Section(header: Text("Game Controller").font(.small)) {
            OptionsSwitchRow(isOn: $viewModel.controllerInvertYAxis, label: "Invert Y-Axis for Aiming/Right Stick")
          }

          #if ZERO
          if PurchaseViewModel.shared.isPurchased {
            appIconSection
          }
          #else
          appIconSection
          #endif
        }
      }.navigationTitle("Settings")
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button(action: {
              viewModel.aimSensitivity = 1.4
              viewModel.touchControlsOpacity = 0.8
              viewModel.touchControlHapticFeedback = true
              viewModel.enableTouchControlsGuideOverlay = true
              viewModel.controllerInvertYAxis = false
              viewModel.gyroEnabled = true
              viewModel.gyroSensitivity = 5.0
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
