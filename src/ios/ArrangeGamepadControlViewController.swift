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
  
  var currentProfile: GamepadButtonLayoutProfile? {
    didSet {
      if let currentProfile {
        GamepadButtonProfileManager().makeLastUsed(currentProfile)
        currentProfileLabel.text = "Current Profile: \(currentProfile.name)"
      }
    }
  }
  
  var buttonPositions = [GamepadButtonPosition]()
  var colorPositions = [GamepadButtonColor]()
  var buttonSizes = [CGFloat]()
  
  var currentControlViews = [UIView]()
  
  let addControlButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
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
    slider.widthAnchor.constraint(equalToConstant: 100).isActive = true
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
  
  let alignHorizontalButton: UIButton = {
    var selectedConfig = UIButton.Configuration.filled()
    selectedConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
    selectedConfig.baseForegroundColor = .red
    selectedConfig.baseBackgroundColor = .gray
    selectedConfig.imagePadding = 10
    selectedConfig.image = UIImage(systemName: "align.vertical.center.fill")
    let button = UIButton(configuration: selectedConfig)
    button.isSelected = true
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  let alignVerticalButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
    configuration.baseForegroundColor = .red
    configuration.baseBackgroundColor = .gray
    configuration.image = UIImage(systemName: "align.horizontal.center.fill")
    let button = UIButton(configuration: configuration)
    button.isSelected = true
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
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
  
  let profilesButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24)
    configuration.baseForegroundColor = .white
    configuration.baseBackgroundColor = .darkGray
    var container = AttributeContainer()
    container.font = UIFont(name: "PerfectDOSVGA437", size: 24)
    configuration.attributedTitle = AttributedString("Profiles", attributes: container)
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
  
  private let currentProfileLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 1
    label.font = UIFont(name: "PerfectDOSVGA437", size: 18)
    label.textColor = .green
    label.alpha = 0.8
    label.textAlignment = .center
    return label
  }()

  private func startInfiniteTransition() {
    UIView.transition(with: currentProfileLabel, duration: 0.5, options: [.transitionCrossDissolve], animations: {
      // Any changes you want to animate
      self.currentProfileLabel.textColor = self.currentProfileLabel.textColor == .green ? .white : .green
    }) { _ in
      // Recursively call the function to repeat the animation
      self.startInfiniteTransition()
    }
  }
  
  var onSaveClosure: (() -> Void)?
  
  var touchControlsOpacitySetValue: Float?
  
  var needsSavingOfDefaultControls = false
  
  override func viewDidLoad() {
    view.backgroundColor = .black
    
    view.addSubview(addControlButton)
    addControlButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    addControlButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
    addControlButton.addTarget(self, action: #selector(addControlButtonPressed(_:)), for: .touchUpInside)
    
    alignHorizontalButton.addTarget(self, action: #selector(alignButtonPressed(_:)), for: .touchUpInside)
    alignVerticalButton.addTarget(self, action: #selector(alignButtonPressed(_:)), for: .touchUpInside)
    
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
    
    view.addSubview(alignHorizontalButton)
    view.addSubview(alignVerticalButton)
    NSLayoutConstraint.activate([
      alignHorizontalButton.leadingAnchor.constraint(equalTo: sliderStack.trailingAnchor, constant: 8),
      alignHorizontalButton.centerYAnchor.constraint(equalTo: addControlButton.centerYAnchor),
      alignVerticalButton.leadingAnchor.constraint(equalTo: alignHorizontalButton.trailingAnchor, constant: 8),
      alignVerticalButton.centerYAnchor.constraint(equalTo: addControlButton.centerYAnchor)
    ])
    
    view.addSubview(cancelButton)
    cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    cancelButton.topAnchor.constraint(equalTo: addControlButton.topAnchor).isActive = true
    cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
    
    trashIcon.frame = CGRect(x: (view.bounds.width - 50) / 2, y: 54, width: 30, height: 30)
    view.addSubview(trashIcon)
    
//    view.addSubview(saveButton)
//    saveButton.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8).isActive = true
//    saveButton.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
//    saveButton.addTarget(self, action: #selector(saveButtonPressed(_:)), for: .touchUpInside)

    view.addSubview(profilesButton)
    profilesButton.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8).isActive = true
    profilesButton.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
    profilesButton.addTarget(self, action: #selector(profilesButtonPressed(_:)), for: .touchUpInside)

    view.addSubview(saveButton)
    saveButton.trailingAnchor.constraint(equalTo: profilesButton.leadingAnchor, constant: -8).isActive = true
    saveButton.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
    saveButton.addTarget(self, action: #selector(saveButtonPressed(_:)), for: .touchUpInside)

    view.addSubview(instructionsLabel)
    instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    instructionsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

    view.addSubview(currentProfileLabel)
    currentProfileLabel.bottomAnchor.constraint(equalTo: instructionsLabel.topAnchor, constant: -20).isActive = true
    currentProfileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//    startInfiniteTransition()
    
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
//    let optionsModel = ControlOptionsViewModel.shared
//    opacitySlider.value = optionsModel.touchControlsOpacity
//    updateOpacity(to: optionsModel.touchControlsOpacity)
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
  
  @objc func alignButtonPressed(_ sender: UIButton) {
    sender.isSelected.toggle()
    if sender.isSelected {
      sender.configuration?.baseForegroundColor = .red
      sender.configuration?.baseBackgroundColor = .white
    } else {
      sender.configuration?.baseForegroundColor = .white
      sender.configuration?.baseBackgroundColor = .gray
    }
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
    guard let currentProfile else {
      print("Current profile does not exist yet!")
      return
    }
    saveCurrent(name: currentProfile.name)
    dismiss(animated: true)
  }
  
  var createProfileAlert: UIAlertController?
  
  @objc func profilesButtonPressed(_ sender: UIButton) {
    guard let currentProfile else {
      print("Current profile does not exist yet!")
      return
    }
    let alert = UIAlertController(title: "Current Profile:\n\(currentProfile.name)", message: "", preferredStyle: .actionSheet)

    alert.addAction(UIAlertAction(title: "Save as New Profile", style: .default, handler: { _ in
      let createAlert = UIAlertController(title: "New Profile", message: "Enter Profile Name:", preferredStyle: .alert)
      createAlert.addTextField()
      createAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
        guard let text = createAlert.textFields?.first?.text, !text.isEmpty else {
          let errorAlert = UIAlertController(title: "Missing Name", message: "Please enter a name for the profile.", preferredStyle: .alert)
          errorAlert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
            self.present(createAlert, animated: true)
          }))
          self.present(errorAlert, animated: true)
          return
        }
        let allProfiles = GamepadButtonProfileManager().get()
        guard allProfiles[text] == nil else {
          let errorAlert = UIAlertController(title: "Profile Exists", message: "A profile exists with that name. Would you like to overwrite it?", preferredStyle: .alert)
          errorAlert.addAction(UIAlertAction(title: "Overwrite", style: .destructive, handler: { _ in
            self.saveCurrent(name: text)
            self.loadSavedControls()
          }))
          errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
          self.present(errorAlert, animated: true)
          return
        }
        self.saveCurrent(name: text)
        self.loadSavedControls()
      }))
      createAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      self.createProfileAlert = createAlert
      self.present(createAlert, animated: true) {
        if UIDevice.current.userInterfaceIdiom == .pad,
           let alertController = self.createProfileAlert {
          alertController.view.frame.origin.y = alertController.view.frame.origin.y - 100
        }
      }
    }))

    alert.addAction(UIAlertAction(title: "Load Profile", style: .default, handler: { _ in
      var view = SelectProfileView()
      view.onSelect = { profile in
        self.currentProfile = profile
        self.loadSavedControls()
        self.dismiss(animated: true)
      }
      view.onCancel = {
        self.dismiss(animated: true)
      }
      let hostingController = UIHostingController(rootView: view)
      self.present(hostingController, animated: true)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    alert.addAction(UIAlertAction(title: "Reset this profile to default", style: .default, handler: { [weak self] _ in
      guard let self, let currentProfile = self.currentProfile else {
        return
      }
      let confirmAlert = UIAlertController(title: "Reset profile", message: "This will overwrite and reset the current profile back to the default layout. Are you sure?", preferredStyle: .alert)
      confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      confirmAlert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
        for controlView in self.view.subviews {
          if controlView is DPadView || controlView is GamepadButtonView {
            controlView.removeFromSuperview()
          }
        }
        GamepadControl.createDefaultPositions(to: self.view)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        var controlPositions = [GamepadButtonPosition]()
        for controlView in self.view.subviews {
          if controlView is DPadView || controlView is GamepadButtonView {
            if let control = GamepadControl(rawValue: controlView.tag) {
              let pos = GamepadButtonPosition(button: control, originX: Float(controlView.frame.origin.x), originY: Float(controlView.frame.origin.y))
              controlPositions.append(pos)
            }
          }
        }
        self.currentProfile = GamepadButtonLayoutProfile(
          name: currentProfile.name,
          positions: controlPositions,
          colors: [],
          sizes: [],
          opacity: self.opacitySlider.value,
          lastUpdatedAt: Date()
        )
        if let updatedProfile = self.currentProfile {
          GamepadButtonProfileManager().save(updatedProfile)
        }
      }))
      self.present(confirmAlert, animated: true)
    }))
    if let currentProfile = self.currentProfile,
       currentProfile.name != "Default",
       let defaultProfile = GamepadButtonProfileManager().get()["Default"] {
      alert.addAction(UIAlertAction(title: "Delete this Profile", style: .destructive, handler: { _ in
        let confirmAlert = UIAlertController(title: "Delete Profile", message: "Are you sure?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
          guard let profileToDelete = self.currentProfile else { return }
          GamepadButtonProfileManager().delete(profileToDelete)
          self.currentProfile = defaultProfile
          self.loadSavedControls()
        }))
        self.present(confirmAlert, animated: true)
      }))
    }
    alert.view.tintColor = .orange
    
    if let popoverController = alert.popoverPresentationController {
      popoverController.sourceView = sender
      popoverController.sourceRect = sender.bounds
      popoverController.permittedArrowDirections = [.down]
    }
    
    present(alert, animated: true)
  }
  
  private func saveCurrent(name: String) {
    buttonPositions = []
    colorPositions = []
    buttonSizes = []
    
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
        buttonSizes.append(subview.frame.size.width)
      } else if let dpadView = subview as? DPadView,
        let gamepadControl = GamepadControl(rawValue: dpadView.tag) {
          buttonPositions.append(
            GamepadButtonPosition(
              button: gamepadControl,
              originX: Float(dpadView.frame.origin.x),
              originY: Float(dpadView.frame.origin.y)
            )
          )
        buttonSizes.append(subview.frame.size.width)
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

    let profile = GamepadButtonLayoutProfile(
      name: name,
      positions: buttonPositions,
      colors: colorPositions,
      sizes: buttonSizes,
      opacity: opacitySlider.value,
      lastUpdatedAt: Date()
    )
    currentProfile = profile
    GamepadButtonProfileManager().save(profile)
    
    #if DEBUG
    print("Saved buttonPositions: \(buttonPositions)")
    print("Saved colorPositions: \(colorPositions)")
    print("Saved sizes: \(buttonSizes)")
    #endif
    
    onSaveClosure?()
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
  
  private func addControl(_ control: GamepadControl, xPos: Float? = nil, yPos: Float? = nil, color: UIColor? = nil, size: GamepadButtonSize? = .medium) {
    let controlView = control.view
    controlView.translatesAutoresizingMaskIntoConstraints = true
    controlView.tag = control.rawValue
    (controlView as? GamepadButtonView)?.widthConstraint?.isActive = false
    (controlView as? GamepadButtonView)?.heightConstraint?.isActive = false
    let xPosn: CGFloat = CGFloat(xPos ?? Float((self.view.frame.width - 50) / 2))
    let yPosn: CGFloat = CGFloat(yPos ?? Float((self.view.frame.height - 50) / 2))
    let size: CGFloat = controlView is DPadView ? 150 : (size?.rawValue ?? 80)
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
    if currentProfile == nil {
      if let fetchedProfile = GamepadButtonProfileManager().getCurrent() {
        currentProfile = fetchedProfile
      } else {
        // create default
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
        currentProfile = GamepadButtonLayoutProfile(
          name: "Default",
          positions: controlPositions,
          colors: [],
          sizes: [],
          opacity: opacitySlider.value,
          lastUpdatedAt: Date()
        )
        if let currentProfile {
          GamepadButtonProfileManager().save(currentProfile)
        }
        return
      }
    }
    
    guard let currentProfile else { return }

    for controlView in view.subviews {
      if controlView is DPadView || controlView is GamepadButtonView {
        controlView.removeFromSuperview()
      }
    }
    currentProfile.positions.enumerated().forEach { index, pos in
      let customizedColor: UIColor? = currentProfile.colors[safe: index]?.uiColor
      let buttonSize = GamepadButtonSize(rawValue: currentProfile.sizes[safe: index] ?? GamepadButtonSize.medium.rawValue)
      self.addControl(pos.button, xPos: pos.originX, yPos: pos.originY, color: customizedColor, size: buttonSize)
    }
    view.bringSubviewToFront(overlayView)
    updateOpacity(to: currentProfile.opacity)
    opacitySlider.value = currentProfile.opacity
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
        alignableView.updateGuides(
          using: self.view.subviews.filter { $0 is AlignableView },
          alignHorizontal: alignHorizontalButton.isSelected,
          alignVertical: alignVerticalButton.isSelected
        )
      }
      
      if gesture.state == .ended {
        alignableView.snapToNearestGuide(
          using: self.view.subviews.filter { $0 is AlignableView },
          alignHorizontal: alignHorizontalButton.isSelected,
          alignVertical: alignVerticalButton.isSelected
        )
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

struct SelectProfileView: View {
  @State private var searchText = ""
  @State private var profiles = GamepadButtonProfileManager().getList()
  
  var onSelect: ((GamepadButtonLayoutProfile) -> Void)?
  var onCancel: (() -> Void)?
  
  var filtered: [GamepadButtonLayoutProfile] {
    let filtered = searchText.isEmpty ? profiles : profiles.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    if let defaultIndex = filtered.firstIndex(where: { $0.name == "Default" }) {
      var filteredWithDefaultOnTop = filtered
      let removed = filteredWithDefaultOnTop.remove(at: defaultIndex)
      filteredWithDefaultOnTop.insert(removed, at: 0)
      return filteredWithDefaultOnTop
    }
    return filtered
  }
  
  var body: some View {
    NavigationWrapper {
      VStack {
        TextField("Search...", text: $searchText)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        List(filtered, id:\.name) { profile in
          Button(action: {
            onSelect?(profile)
          }, label: {
            Text(profile.name).font(.body).foregroundStyle(profile.name == "Default" ? .blue : .cyan)
          })
          .swipeActions {
            if profile.name != "Default" {
              Button(role: .destructive) {
                var saved = GamepadButtonProfileManager().get()
                saved.removeValue(forKey: profile.name)
                GamepadButtonProfileManager().save(profilesDict: saved)
                profiles = GamepadButtonProfileManager().getList()
              } label: {
                Image(systemName: "trash")
              }
            }
          }
        }
      }.navigationTitle("Select a Profile").font(.body).foregroundStyle(.white)
        .navigationBarItems(trailing: Button(action: {
          onCancel?()
        }, label: {
          Text("Cancel").font(.body).foregroundStyle(.white)
        }))
    }
  }
}
