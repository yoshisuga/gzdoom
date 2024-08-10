//
//  TVOSUIHandler.swift
//  zdoom-tvOS
//
//  Created by Yoshi Sugawara on 8/6/24.
//

import SwiftUI

class ControlOptionsWrapperViewController: GCEventViewController {
  let optionsView: any View

  init(optionsView: any View) {
    self.optionsView = optionsView
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    controllerUserInteractionEnabled = true
    let hostingController = UIHostingController(rootView: AnyView(optionsView))
    addChild(hostingController)
    hostingController.didMove(toParent: self)
    hostingController.view.frame = view.bounds
    view.addSubview(hostingController.view)
  }
  
  override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    super.pressesBegan(presses, with: event)
  }
}

@objcMembers class TVOSUIHandler: NSObject {
  static let shared = TVOSUIHandler()
  
  weak var rootViewController: UIViewController?
  
  func showOptionsScreen(beforePresent: () -> Void, afterDismiss: @escaping () -> Void) {
    guard let rootViewController, rootViewController.presentedViewController == nil else {
      return
    }
    var optionsView = ControlOptionsView()
    optionsView.dismissClosure = { [weak self] in
      afterDismiss()
      SDL_SetHint(SDL_HINT_APPLE_TV_CONTROLLER_UI_EVENTS, "0")
      self?.rootViewController?.dismiss(animated: true)
    }
    beforePresent()
    SDL_SetHint(SDL_HINT_APPLE_TV_CONTROLLER_UI_EVENTS, "1")
    rootViewController.present(ControlOptionsWrapperViewController(optionsView: optionsView), animated: true)
  }
}
