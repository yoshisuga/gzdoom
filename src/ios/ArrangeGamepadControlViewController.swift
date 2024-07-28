//
//  ArrangeGamepadControlViewController.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/27/24.
//

import Foundation
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
  
  var currentControlViews = [UIView]()
  
  let addControlButton: UIButton = {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Add Control", for: .normal)
    return button
  }()
  
  let cancelButton: UIButton = {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Cancel", for: .normal)
    button.setTitleColor(.red, for: .normal)
    return button
  }()
  
  let trashIcon: UIImageView = {
    let trashIcon = UIImageView(image: UIImage(systemName: "trash"))
    trashIcon.tintColor = .red
    return trashIcon
  }()
  
  let saveButton: UIButton = {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Save", for: .normal)
    button.setTitleColor(.green, for: .normal)
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
  
  var onSaveClosure: (() -> Void)?
  
  override func viewDidLoad() {
    view.backgroundColor = .black
    
    view.addSubview(addControlButton)
    addControlButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    addControlButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
    addControlButton.addTarget(self, action: #selector(addControlButtonPressed(_:)), for: .touchUpInside)
    
    
    view.addSubview(cancelButton)
    cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    cancelButton.topAnchor.constraint(equalTo: addControlButton.topAnchor).isActive = true
    cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
    
    trashIcon.frame = CGRect(x: (view.bounds.width - 50) / 2, y: 16, width: 40, height: 40)
    view.addSubview(trashIcon)
    
    view.addSubview(saveButton)
    saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
    saveButton.addTarget(self, action: #selector(saveButtonPressed(_:)), for: .touchUpInside)
    
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
    addControlView?.widthAnchor.constraint(equalToConstant: 500).isActive = true
    addControlView?.heightAnchor.constraint(equalToConstant: 300).isActive = true
    addControlView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    addControlView?.isHidden = true
    addControlView?.layer.cornerRadius = 15
    addControlVC.didMove(toParent: self)
    
    addControlVC.didSelectControlClosure = { control in
      self.addControl(control)
      self.viewMode = .arrange
    }

    view.bringSubviewToFront(overlayView)
    updateAccordingToViewMode()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadSavedControls()
  }
  
  @objc func addControlButtonPressed(_ sender: UIButton) {
    viewMode = .addControl
  }
  
  @objc func cancelButtonPressed(_ sender: UIButton) {
    dismiss(animated: true)
  }
  
  @objc func saveButtonPressed(_ sender: UIButton) {
    buttonPositions = view.subviews.compactMap { subview in
      if let gamepadButtonView = subview as? GamepadButtonView,
         let gamepadControl = GamepadControl(rawValue: gamepadButtonView.tag) {
        return GamepadButtonPosition(button: gamepadControl, originX: Float(gamepadButtonView.frame.origin.x), originY: Float(gamepadButtonView.frame.origin.y))
      } else if let dpadView = subview as? DPadView,
                let gamepadControl = GamepadControl(rawValue: dpadView.tag) {
        return GamepadButtonPosition(button: gamepadControl, originX: Float(dpadView.frame.origin.x), originY: Float(dpadView.frame.origin.y))
      }
      return nil
    }

    if let saveData = try? PropertyListEncoder().encode(buttonPositions) {
      UserDefaults.standard.set(saveData, forKey: GamepadButtonPosition.userDefaultsKey)
    }
    print("Saved buttonPositions: \(buttonPositions)")
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
  
  private func addControl(_ control: GamepadControl, xPos: Float? = nil, yPos: Float? = nil) {
    let controlView = control.view
    controlView.translatesAutoresizingMaskIntoConstraints = true
    controlView.tag = control.rawValue
    let xPosn: CGFloat = CGFloat(xPos ?? Float((self.view.frame.width - 50) / 2))
    let yPosn: CGFloat = CGFloat(yPos ?? Float((self.view.frame.height - 50) / 2))
    let size: CGFloat = controlView is DPadView ? 150 : 50
    controlView.frame = CGRect(x: xPosn, y: yPosn, width: size, height: size)
    view.addSubview(controlView)
    view.bringSubviewToFront(overlayView)
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    controlView.addGestureRecognizer(panGesture)
  }
  
  private func loadSavedControls() {
    guard let saveData = UserDefaults.standard.data(forKey: GamepadButtonPosition.userDefaultsKey),
          let controlPositions = try? PropertyListDecoder().decode([GamepadButtonPosition].self, from: saveData) else { return }
    for controlView in view.subviews {
      if controlView is DPadView || controlView is GamepadButtonView {
        controlView.removeFromSuperview()
      }
    }
    for controlView in view.subviews {
      if controlView is DPadView || controlView is GamepadButtonView {
        controlView.removeFromSuperview()
      }
    }
    controlPositions.forEach { self.addControl($0.button, xPos: $0.originX, yPos: $0.originY) }
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
      (viewToMove as? GamepadButtonView)?.imageView.tintColor = .blue
    } else {
      (viewToMove as? GamepadButtonView)?.imageView.tintColor = .gray
    }
    
    // Check if the view is over the trash icon
    if trashIcon.frame.contains(viewToMove.center) {
      UIView.animate(withDuration: 0.2) {
        self.trashIcon.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
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
}
