//
//  ArrangeGamepadControlViewController.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import Foundation
import SwiftUI
import UIKit

class ArrangeGamepadControlViewController: UIViewController {
  
  enum ViewMode {
    case arrange, addControl
  }
  
  var viewMode = ViewMode.arrange {
    didSet {
      updateAccordingToViewMode()
    }
  }
  
  var buttonPositions = [GamepadButtonPosition]()
  var colorPositions = [GamepadButtonColor]()
  
  var currentControlViews = [UIView]()
  
  let addControlButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    configuration.baseForegroundColor = .white
    configuration.baseBackgroundColor = .darkGray
    var container = AttributeContainer()
    container.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    configuration.attributedTitle = AttributedString("+", attributes: container)
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  let opacitySlider: UISlider = {
    let slider = UISlider()
    slider.tintColor = .red
    slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
    slider.minimumValue = 0.1
    slider.maximumValue = 1.0
    return slider
  }()
  
  let opacityIcon: UIImageView = {
    let imageView = UIImageView(image: UIImage(systemName: "circle.righthalf.filled"))
    imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    imageView.tintColor = .red
    return imageView
  }()
  
  let cancelButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
    configuration.baseForegroundColor = .red
    configuration.baseBackgroundColor = .darkGray
    var container = AttributeContainer()
    container.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    configuration.attributedTitle = AttributedString("Cancel", attributes: container)
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  let trashIcon: UIImageView = {
    let trashIcon = UIImageView(image: UIImage(systemName: "trash"))
    trashIcon.tintColor = .red
    return trashIcon
  }()
  
  let resetButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24)
    configuration.baseForegroundColor = .white
    configuration.baseBackgroundColor = .darkGray
    var container = AttributeContainer()
    container.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    configuration.attributedTitle = AttributedString("Reset", attributes: container)
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  let saveButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24)
    configuration.baseForegroundColor = .green
    configuration.baseBackgroundColor = .darkGray
    var container = AttributeContainer()
    container.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    configuration.attributedTitle = AttributedString("Save", attributes: container)
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  var addControlView: UIView?
  
  private let overlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let blurEffectView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .light)
    let view = UIVisualEffectView(effect: blurEffect)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let instructionsLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 3
    label.text = "Tap and drag to move controls.\nTap to show customization options.\nDrag to the trash icon to remove."
    label.font = UIFont(name: "PerfectDOSVGA437", size: 18)
    label.alpha = 0.5
    label.textAlignment = .center
    return label
  }()
  
  var onSaveClosure: (() -> Void)?
  
  var touchControlsOpacitySetValue: Float?
  
  var needsSavingOfDefaultControls = false
  
  override func viewDidLoad() {
    view.backgroundColor = .black
    
    view.addSubview(addControlButton)
    addControlButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    addControlButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
    addControlButton.addTarget(self, action: #selector(addControlButtonPressed(_:)), for: .touchUpInside)
    
    let sliderStack = UIStackView(arrangedSubviews: [
      opacityIcon, opacitySlider
    ])
    sliderStack.spacing = 4
    sliderStack.axis = .horizontal
    sliderStack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(sliderStack)
    sliderStack.leadingAnchor.constraint(equalTo: addControlButton.trailingAnchor, constant: 16).isActive = true
    sliderStack.centerYAnchor.constraint(equalTo: addControlButton.centerYAnchor).isActive = true
    opacitySlider.addTarget(self, action: #selector(opacitySliderChanged(_:)), for: .valueChanged)
        
    view.addSubview(cancelButton)
    cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    cancelButton.topAnchor.constraint(equalTo: addControlButton.topAnchor).isActive = true
    cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
    
    trashIcon.frame = CGRect(x: (view.bounds.width - 50) / 2, y: 54, width: 30, height: 30)
    view.addSubview(trashIcon)
    
    view.addSubview(saveButton)
    saveButton.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8).isActive = true
    saveButton.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
    saveButton.addTarget(self, action: #selector(saveButtonPressed(_:)), for: .touchUpInside)

    view.addSubview(resetButton)
    resetButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8).isActive = true
    resetButton.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
    resetButton.addTarget(self, action: #selector(resetButtonPressed(_:)), for: .touchUpInside)

    view.addSubview(instructionsLabel)
    instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    instructionsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    view.addSubview(overlayView)
    overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    overlayView.addSubview(blurEffectView)
    
    blurEffectView.topAnchor.constraint(equalTo: overlayView.topAnchor).isActive = true
    blurEffectView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor).isActive = true
    blurEffectView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor).isActive = true
    blurEffectView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor).isActive = true
    
    let addControlVC = AddGamepadControlViewController()
    addChild(addControlVC)
    overlayView.addSubview(addControlVC.view)
    addControlView = addControlVC.view
    addControlView?.translatesAutoresizingMaskIntoConstraints = false
    addControlView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    addControlView?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    addControlView?.widthAnchor.constraint(equalToConstant: 660).isActive = true
    addControlView?.heightAnchor.constraint(equalToConstant: 345).isActive = true
    addControlView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    addControlView?.isHidden = true
    addControlView?.layer.cornerRadius = 15
    addControlVC.didMove(toParent: self)
    
    addControlVC.didSelectControlClosure = { control in
      self.addControl(control)
      self.viewMode = .arrange
    }
    
    addControlVC.didCloseClosure = {
      self.viewMode = .arrange
    }

    view.bringSubviewToFront(overlayView)
    updateAccordingToViewMode()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadSavedControls()
    let optionsModel = ControlOptionsViewModel.shared
    opacitySlider.value = optionsModel.touchControlsOpacity
    updateOpacity(to: optionsModel.touchControlsOpacity)
  }

  private func updateOpacity(to opacity: Float) {
    view.subviews.filter { $0 is GamepadButtonView || $0 is DPadView }.forEach { controlView in
      controlView.alpha = CGFloat(opacity)
    }
  }
  
  @objc func opacitySliderChanged(_ sender: UISlider) {
    touchControlsOpacitySetValue = sender.value
    updateOpacity(to: sender.value)
  }
  
  @objc func addControlButtonPressed(_ sender: UIButton) {
    viewMode = .addControl
  }
  
  @objc func cancelButtonPressed(_ sender: UIButton) {
    self.onSaveClosure?()
    dismiss(animated: true)
  }
  
  @objc func resetButtonPressed(_ sender: UIButton) {
    for controlView in view.subviews {
      if controlView is DPadView || controlView is GamepadButtonView {
        controlView.removeFromSuperview()
      }
    }
    GamepadControl.createDefaultPositions(to: view)

    view.setNeedsLayout()
    view.layoutIfNeeded()
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
        print("Reset with default controls....")
      }
      for controlView in view.subviews {
        if controlView is DPadView || controlView is GamepadButtonView {
          controlView.removeFromSuperview()
        }
      }
      
      // remove color positions
      UserDefaults.standard.removeObject(forKey: GamepadButtonColor.userDefaultsKey)
      
      loadSavedControls()
    }

    view.bringSubviewToFront(overlayView)
    
    updateOpacity(to: ControlOptionsViewModel.shared.touchControlsOpacity)
  }
  
  @objc func saveButtonPressed(_ sender: UIButton) {
    buttonPositions = []
    colorPositions = []
    
    view.subviews.forEach { subview in
      var red: CGFloat = 0
      var blue: CGFloat = 0
      var green: CGFloat = 0

      if let gamepadButtonView = subview as? GamepadButtonView,
         let gamepadControl = GamepadControl(rawValue: gamepadButtonView.tag) {

        buttonPositions.append(
          GamepadButtonPosition(
            button: gamepadControl,
            originX: Float(gamepadButtonView.frame.origin.x),
            originY: Float(gamepadButtonView.frame.origin.y)
          )
        )

      } else if let dpadView = subview as? DPadView,
        let gamepadControl = GamepadControl(rawValue: dpadView.tag) {
          buttonPositions.append(
            GamepadButtonPosition(
              button: gamepadControl,
              originX: Float(dpadView.frame.origin.x),
              originY: Float(dpadView.frame.origin.y)
            )
          )
      }
      
      if let customizableColorView = subview as? CustomizableColor {
        if let customizedColor = customizableColorView.customizedColor {
          customizedColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        } else {
          UIColor.gray.getRed(&red, green: &green, blue: &blue, alpha: nil)
        }
        colorPositions.append(
          GamepadButtonColor(red: red, green: green, blue: blue)
        )
      }
    }

    if let saveData = try? PropertyListEncoder().encode(buttonPositions) {
      UserDefaults.standard.set(saveData, forKey: GamepadButtonPosition.userDefaultsKey)
    }
    if let saveColorData = try? PropertyListEncoder().encode(colorPositions) {
      UserDefaults.standard.set(saveColorData, forKey: GamepadButtonColor.userDefaultsKey)
    }
    
    print("Saved buttonPositions: \(buttonPositions)")
    print("Saved colorPositions: \(colorPositions)")
    
    // save opacity setting
    if let touchControlsOpacitySetValue {
      let optionsModel = ControlOptionsViewModel.shared
      optionsModel.touchControlsOpacity = touchControlsOpacitySetValue
      optionsModel.saveToUserDefaults()
    }
    
    dismiss(animated: true) {
      self.onSaveClosure?()
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let firstTouch = touches.first {
      let hitView = self.view.hitTest(firstTouch.location(in: self.overlayView), with: event)
      if hitView != self.addControlView {
        if viewMode == .addControl {
          viewMode = .arrange
        }
      }
    }
  }
  
  private func updateAccordingToViewMode() {
    switch viewMode {
    case .arrange:
      overlayView.isHidden = true
      addControlView?.isHidden = true
    case .addControl:
      overlayView.isHidden = false
      addControlView?.isHidden = false
    }
  }
  
  private func addControl(_ control: GamepadControl, xPos: Float? = nil, yPos: Float? = nil, color: UIColor? = nil) {
    let controlView = control.view
    controlView.translatesAutoresizingMaskIntoConstraints = true
    controlView.tag = control.rawValue
    let xPosn: CGFloat = CGFloat(xPos ?? Float((self.view.frame.width - 50) / 2))
    let yPosn: CGFloat = CGFloat(yPos ?? Float((self.view.frame.height - 50) / 2))
    let size: CGFloat = controlView is DPadView ? 150 : 80
    controlView.frame = CGRect(x: xPosn, y: yPosn, width: size, height: size)
    if let buttonView = controlView as? GamepadButtonView {
      buttonView.operationMode = .arranging
      buttonView.delegate = self
      buttonView.customizedColor = color 
    } else if let dpad = controlView as? DPadView {
      dpad.isAnimated = false
      dpad.delegate = self
      dpad.customizedColor = color
    }
    view.addSubview(controlView)
    view.bringSubviewToFront(overlayView)
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    controlView.addGestureRecognizer(panGesture)
  }
  
  private func loadSavedControls() {
    guard let saveData = UserDefaults.standard.data(
      forKey: GamepadButtonPosition.userDefaultsKey
      ),
      let controlPositions = try? PropertyListDecoder().decode(
        [GamepadButtonPosition].self,
        from: saveData
      ) else {
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
    
    controlPositions.enumerated().forEach { index, pos in
      let customizedColor: UIColor? = loadedColorPositions[safe: index]?.uiColor
      self.addControl(pos.button, xPos: pos.originX, yPos: pos.originY, color: customizedColor)
    }
    view.bringSubviewToFront(overlayView)
  }

  
  @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: view)
    guard let viewToMove = gesture.view else {
      return
    }
    // Calculate new center
    var newCenter = CGPoint(x: viewToMove.center.x + translation.x, y: viewToMove.center.y + translation.y)
    
    // Restrict movement within screen bounds
    let halfWidth = viewToMove.bounds.width / 2
    let halfHeight = viewToMove.bounds.height / 2
    newCenter.x = max(halfWidth, min(view.bounds.width - halfWidth, newCenter.x))
    newCenter.y = max(halfHeight, min(view.bounds.height - halfHeight, newCenter.y))
    
    viewToMove.center = newCenter
    
    gesture.setTranslation(.zero, in: view)
    
    // Change color while dragging
    if gesture.state == .began || gesture.state == .changed {
      if let buttonView = viewToMove as? GamepadButtonView {
        buttonView.imageView.tintColor = .blue
      }
      if let dpadView = viewToMove as? DPadView {
        dpadView.imageView.tintColor = .blue
      }
    } else {
      if let buttonView = viewToMove as? GamepadButtonView {
        buttonView.imageView.tintColor = buttonView.customizedColor ?? .gray
      }
      if let dpadView = viewToMove as? DPadView {
        dpadView.imageView.tintColor = dpadView.customizedColor ?? .gray
      }
    }
    
    // handle alignment guide
    if let alignableView = viewToMove as? AlignableView {
      if gesture.state == .began {
        alignableView.initialCenter = newCenter
        alignableView.showGuides()
      }
      
      if gesture.state != .cancelled {
        alignableView.updateGuides(using: self.view.subviews.filter { $0 is AlignableView })
      }
      
      if gesture.state == .ended {
        alignableView.snapToNearestGuide(using: self.view.subviews.filter { $0 is AlignableView })
        alignableView.hideGuides()
      }
    }
    
    // Check if the view is over the trash icon
    if trashIcon.frame.contains(viewToMove.center) {
      UIView.animate(withDuration: 0.2) {
        self.trashIcon.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
      }
    } else {
      UIView.animate(withDuration: 0.2) {
        self.trashIcon.transform = CGAffineTransform.identity
      }
    }
    
    // Remove the view if it's over the trash icon when the gesture ends
    if gesture.state == .ended {
      if trashIcon.frame.contains(viewToMove.center) {
        viewToMove.removeFromSuperview()
        UIView.animate(withDuration: 0.2) {
          self.trashIcon.transform = CGAffineTransform.identity
        }
      }
    }
  }
  
  var buttonSelectedForCustomizingColor: CustomizableColor?
}

extension ArrangeGamepadControlViewController: GamepadButtonDelegate {
  func gamepadButton(pressed button: GamepadButtonView, isMove: Bool) {
  }
  
  func gamepadButton(released button: GamepadButtonView, touches: Set<UITouch>, event: UIEvent?) {
  }
  
  func gamepadButton(customizeColorPressed button: GamepadButtonView) {
    let colorPicker = UIColorPickerViewController()
    colorPicker.title = "Button \(button.buttonName)"
    colorPicker.supportsAlpha = false
    colorPicker.delegate = self
    colorPicker.modalPresentationStyle = .automatic
    buttonSelectedForCustomizingColor = button
    present(colorPicker, animated: true)
  }
}

extension ArrangeGamepadControlViewController: DPadDelegate {
  func dPad(_ dPadView: DPadView, didPress: DPadDirection) {
  }
  
  func dPadDidRelease(_ dPadView: DPadView) {
  }
  
  func dPad(colorCustomized dPadView: DPadView) {
    let colorPicker = UIColorPickerViewController()
    colorPicker.title = "D-Pad"
    colorPicker.supportsAlpha = false
    colorPicker.delegate = self
    colorPicker.modalPresentationStyle = .automatic
    buttonSelectedForCustomizingColor = dPadView
    present(colorPicker, animated: true)
  }
}

extension ArrangeGamepadControlViewController: UIColorPickerViewControllerDelegate {
  func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
    print("Picked color: \(color)")
    var selectedRed: CGFloat = 0
    var selectedGreen: CGFloat = 0
    var selectedBlue: CGFloat = 0
    color.getRed(&selectedRed, green: &selectedGreen, blue: &selectedBlue, alpha: nil)
    if selectedRed < 0.2 && selectedGreen < 0.2 && selectedBlue < 0.2 {
      buttonSelectedForCustomizingColor?.customizedColor = .gray
    } else {
      buttonSelectedForCustomizingColor?.customizedColor = color
    }
  }
}

struct ArrangeControlsView: UIViewControllerRepresentable {
  typealias UIViewControllerType = ArrangeGamepadControlViewController
  
  func makeUIViewController(context: Context) -> ArrangeGamepadControlViewController {
    let vc = ArrangeGamepadControlViewController()
    return vc
  }
  
  func updateUIViewController(_ uiViewController: ArrangeGamepadControlViewController, context: Context) {
  }
}

