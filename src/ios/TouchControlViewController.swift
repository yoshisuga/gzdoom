//
//  GameControlViewController.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import UIKit

class TouchControlViewController: UIViewController {
  var needsSavingOfDefaultControls = false
  let generator = UIImpactFeedbackGenerator(style: .light)
  
  var lastTouchTime: TimeInterval? {
    didSet {
      guideOverlayView.isHidden = true
    }
  }
  private let guideOverlayTimeIntervalThreshold: TimeInterval = 4
  let guideOverlayView = TouchControlGuideOverlayView()
  var guideTimer: Timer?
  var guideNumberOfTimesShown = 0
  
  var aimControlsView = AimControlsView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guideOverlayView.isHidden = true
    view.addSubview(guideOverlayView)
    guideOverlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    guideOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    guideOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    guideOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
    let joystick = JoystickView()
    joystick.translatesAutoresizingMaskIntoConstraints = false
    joystick.backgroundColor = .clear
    view.addSubview(joystick)
    joystick.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    joystick.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    joystick.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    joystick.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    joystick.delegate = self
    
    aimControlsView = AimControlsView()
    aimControlsView.translatesAutoresizingMaskIntoConstraints = false
    aimControlsView.backgroundColor = .clear
    view.addSubview(aimControlsView)
    aimControlsView.leadingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    aimControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    aimControlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    aimControlsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    aimControlsView.delegate = self
    
    guideTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(guideTimerFired), userInfo: nil, repeats: true)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadSavedControls()
    updateOpacity()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    lastTouchTime = Date().timeIntervalSince1970
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    guideTimer?.invalidate()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if needsSavingOfDefaultControls {
      var controlPositions = [GamepadButtonPosition]()
      for controlView in view.subviews {
        if controlView is DPadView || controlView is GamepadButtonView {
          if let control = GamepadControl(rawValue: controlView.tag) {
            let pos = GamepadButtonPosition(button: control, originX: Float(controlView.frame.origin.x), originY: Float(controlView.frame.origin.y))
            controlPositions.append(pos)
          }
        }
      }
      if !controlPositions.isEmpty {
        if let saveData = try? PropertyListEncoder().encode(controlPositions) {
          UserDefaults.standard.set(saveData, forKey: GamepadButtonPosition.userDefaultsKey)
          print("Saved default controls....")
        }
      }
      needsSavingOfDefaultControls = false
    }
  }
  
  @objc func guideTimerFired() {
    print("guideTimerFired!")
    if ControlOptionsViewModel.shared.enableTouchControlsGuideOverlay,
       guideOverlayView.isHidden,
       guideNumberOfTimesShown < 1,
        let lastTouchTime,
       Date().timeIntervalSince1970 - lastTouchTime > guideOverlayTimeIntervalThreshold {
      guideOverlayView.alpha = 0
      guideOverlayView.isHidden = false
      UIView.animate(withDuration: 0.5) { [weak self] in
        self?.guideOverlayView.alpha = 1
      }
      guideNumberOfTimesShown += 1
    }
    if guideNumberOfTimesShown >= 1 || !ControlOptionsViewModel.shared.enableTouchControlsGuideOverlay {
      guideTimer?.invalidate()
    }
  }
  
  private func loadSavedControls() {
    guard let saveData = UserDefaults.standard.data(forKey: GamepadButtonPosition.userDefaultsKey),
          let controlPositions = try? PropertyListDecoder().decode([GamepadButtonPosition].self, from: saveData) else {
      needsSavingOfDefaultControls = true
      GamepadControl.createDefaultPositions(to: view, buttonDelegate: self, dpadDelegate: self)
      return
    }
    
    for controlView in view.subviews {
      if controlView is DPadView || controlView is GamepadButtonView {
        controlView.removeFromSuperview()
      }
    }
    
    // read color positions
    var loadedColorPositions = [GamepadButtonColor]()
    if let savedColorData = UserDefaults.standard.data(forKey: GamepadButtonColor.userDefaultsKey),
       let colorPositions = try? PropertyListDecoder().decode([GamepadButtonColor].self, from: savedColorData) {
      loadedColorPositions = colorPositions
    }
    
    // load sizes
    var loadedSizes = [CGFloat]()
    if let savedSizes = UserDefaults.standard.data(forKey: GamepadButtonSize.userDefaultsKey),
       let sizes = try? PropertyListDecoder().decode([CGFloat].self, from: savedSizes) {
      loadedSizes = sizes
    }
     
    controlPositions.enumerated().forEach { index, controlPos in
      let controlView = controlPos.button.view
      controlView.translatesAutoresizingMaskIntoConstraints = true
      controlView.tag = controlPos.button.rawValue
      var size: CGFloat = controlPos.button == .dpad ? 150 : 80
      view.addSubview(controlView)
      let customizedColor = loadedColorPositions[safe: index]?.uiColor
      if let gamepadButton = controlView as? GamepadButtonView {
        gamepadButton.delegate = self
        size = loadedSizes[safe: index] ?? GamepadButtonSize.medium.rawValue
      } else if let dpad = controlView as? DPadView {
        dpad.delegate = self
      }
      controlView.frame = CGRect(x: CGFloat(controlPos.originX), y: CGFloat(controlPos.originY), width: size, height: size)
      if var customizableColorView = controlView as? CustomizableColor {
        customizableColorView.customizedColor = customizedColor
      }
    }
  }

  #if os(iOS)
  @objc func arrangeButtonTapped(_ sender: UIButton) {
    let controller = ArrangeGamepadControlViewController()
    controller.onSaveClosure = {
      self.loadSavedControls()
      self.updateOpacity()
    }
    controller.modalPresentationStyle = .fullScreen
    present(controller, animated: true)
  }
  #endif
  
  func updateOpacity() {
    let optionsModel = ControlOptionsViewModel.shared
    view.subviews.filter { $0 is GamepadButtonView || $0 is DPadView }.forEach { controlView in
      controlView.alpha = CGFloat(optionsModel.touchControlsOpacity)
    }
  }
  
  func changeTouchControls(isHidden: Bool) {
    if isHidden {
      guideOverlayView.isHidden = true
    }
    view.subviews.filter{ $0 is GamepadButtonView || $0 is DPadView }.forEach{ $0.isHidden = isHidden }
  }
}

extension TouchControlViewController: JoystickDelegate {
  func joystickDidStart() {
    changeTouchControls(isHidden: false)
  }
  
  func joystickEnded() {
    guard let utils = IOSUtils.shared() else {
      return
    }
    utils.handleLeftThumbstickDirectionalInput(.up, isPressed: false)
    utils.handleLeftThumbstickDirectionalInput(.down, isPressed: false)
    utils.handleLeftThumbstickDirectionalInput(.right, isPressed: false)
    utils.handleLeftThumbstickDirectionalInput(.left, isPressed: false)
    lastTouchTime = Date().timeIntervalSince1970
  }
  
  func joystickMoved(dx: Float, dy: Float) {
    guard let utils = IOSUtils.shared() else {
      return
    }
    let deadzoneThreshold: Float = 4.0

    if dx > deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.right, isPressed: true)
      utils.handleLeftThumbstickDirectionalInput(.left, isPressed: false)
    } else if dx < -deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.left, isPressed: true)
      utils.handleLeftThumbstickDirectionalInput(.right, isPressed: false)
    } else if dx >= -deadzoneThreshold && dx < deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.right, isPressed: false)
      utils.handleLeftThumbstickDirectionalInput(.left, isPressed: false)
    }
    
    if dy < -deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.up, isPressed: true)
      utils.handleLeftThumbstickDirectionalInput(.down, isPressed: false)
    } else if dy > deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.down, isPressed: true)
      utils.handleLeftThumbstickDirectionalInput(.up, isPressed: false)
    } else if dy >= -deadzoneThreshold && dy < deadzoneThreshold {
      utils.handleLeftThumbstickDirectionalInput(.up, isPressed: false)
      utils.handleLeftThumbstickDirectionalInput(.down, isPressed: false)
    }
    lastTouchTime = Date().timeIntervalSince1970
  }
}

extension TouchControlViewController: AimControlsDelegate {
  func aimDidStart() {
    changeTouchControls(isHidden: false)
  }
  
  func aimEnded() {
    #if DEBUG
    print("aimEnded called!")
    #endif
    MouseInputHolder.shared.deltaX = 0
    MouseInputHolder.shared.deltaY = 0
//    guard let utils = IOSUtils.shared() else { return }

    // Release buttons if the buttons are within the aiming view
//    for subview in view.subviews {
//      guard let gameButton = subview as? GamepadButtonView,
//            let gamepadControl = GamepadControl(rawValue: gameButton.tag) else {
//        continue
//      }
//      if aimControlsView.frame.contains(gameButton.center) {
//        utils.handleGameControl(gamepadControl, isPressed: false)
//      }
//    }
    lastTouchTime = Date().timeIntervalSince1970
  }
  
  func aimDidSingleTap() {
  }
  
  func aimDidDoubleTap() {
//    guard let utils = IOSUtils.shared() else { return }
//    if let control = ControlOptionsViewModel.shared.doubleTapControl.gameControl {
//      utils.handleGameControl(control, isPressed: true)
//      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//        utils.handleGameControl(control, isPressed: false)
//      }
//    }
  }
  
  func aimDidMove(dx: Float, dy: Float, isDoubleTap: Bool) {
//    print("aimDidMove called!")
    let aimSensitivity = ControlOptionsViewModel.shared.aimSensitivity
    let updatedDX = (dx < 0 ? floor(dx) : ceil(dx)) * aimSensitivity
    let updatedDY = (dy < 0 ? floor(dy) : ceil(dy)) * aimSensitivity

    let mouseMoveX: Int = Int(updatedDX)
    let mouseMoveY: Int = Int(updatedDY)
    
//    print("aimDidMove: delta=\(dx),\(dy), aimS=\(aimSensitivity) afterAimSensitivity=\(updatedDX),\(updatedDY) convertedMouseMove=\(mouseMoveX),\(mouseMoveY)")
    
    MouseInputHolder.shared.deltaX = mouseMoveX
    MouseInputHolder.shared.deltaY = mouseMoveY
    lastTouchTime = Date().timeIntervalSince1970
  }
}

extension TouchControlViewController: GamepadButtonDelegate {
  func gamepadButton(began button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {
    guard let touch = touches.first, touch.type == .direct else {
      return
    }
    let touchLocationInButton = touch.location(in: button)
    let convertedTouch = button.convert(touchLocationInButton, to: self.view)
    if aimControlsView.frame.contains(convertedTouch) {
//      print("gamePadButtonBegan: RT button pressed inside of aimControlsView!")
      aimControlsView.touchesBegan(touches, with: event)
    }
  }
  
  func gamepadButton(moved button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {
    guard let touch = touches.first, touch.type == .direct else {
      return
    }
    let touchLocationInButton = touch.location(in: button)
    let convertedTouch = button.convert(touchLocationInButton, to: self.view)
    if aimControlsView.frame.contains(convertedTouch) {
//      print("gamePadButtonBegan: RT button pressed inside of aimControlsView!")
      aimControlsView.touchesMoved(touches, with: event)
    }
  }
  
  func gamepadButton(pressed button: GamepadButtonView, isMove: Bool) {
    guard let utils = IOSUtils.shared(),
          let gamepadControl = GamepadControl(rawValue: button.tag) else {
      return
    }
//    print("gamepadButtonPressed called: \(gamepadControl)")
    utils.handleGameControl(gamepadControl, isPressed: true)
    
    if ControlOptionsViewModel.shared.touchControlHapticFeedback && !isMove {
      generator.impactOccurred()
    }
    lastTouchTime = Date().timeIntervalSince1970
  }
  
  func gamepadButton(released button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {
    guard let utils = IOSUtils.shared(),
          let gamepadControl = GamepadControl(rawValue: button.tag) else {
      return
    }
//    print("gamepadButtonReleased called: \(gamepadControl)")
    utils.handleGameControl(gamepadControl, isPressed: false)
    if aimControlsView.frame.contains(button.center) {
      aimControlsView.touchesEnded(touches, with: event)
    }
    lastTouchTime = Date().timeIntervalSince1970
  }
}

extension TouchControlViewController: DPadDelegate {
  func dPad(_ dPadView: DPadView, didPress: DPadDirection) {
    guard let utils = IOSUtils.shared() else { return }
    utils.handleOverlayDPad(with: dPadView.currentDirection)
    if ControlOptionsViewModel.shared.touchControlHapticFeedback {
      generator.impactOccurred()
    }
    lastTouchTime = Date().timeIntervalSince1970
  }
  
  func dPadDidRelease(_ dPadView: DPadView) {
    guard let utils = IOSUtils.shared() else { return }
    utils.handleOverlayDPad(with: .none)
    lastTouchTime = Date().timeIntervalSince1970
  }
}

class TouchControlGuideOverlayView: UIView {
  let moveOverlay: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 1
    let label = UILabel()
    label.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    label.text = "MOVE"
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60).isActive = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let aimOverlay: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.4)
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 2
    let label = UILabel()
    label.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    label.text = "AIM"
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60).isActive = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  convenience init() {
    self.init(frame: .zero)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    addSubview(moveOverlay)
    moveOverlay.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
    moveOverlay.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
    moveOverlay.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    moveOverlay.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -4).isActive = true
    addSubview(aimOverlay)
    aimOverlay.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 4).isActive = true
    aimOverlay.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
    aimOverlay.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    aimOverlay.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
    translatesAutoresizingMaskIntoConstraints = false
  }
}
