//
//  TVOSUIHandler.swift
//  zdoom-tvOS
//
//  Created by Yoshi Sugawara on 8/6/24.
//

import SwiftUI

@objcMembers class TVOSUIHandler: NSObject {
  static let shared = TVOSUIHandler()
  
  var rootViewController: UIViewController?
  
  func showOptionsScreen() {
    guard let rootViewController, rootViewController.presentedViewController == nil else {
      return
    }
    var optionsView = ControlOptionsView()
    optionsView.dismissClosure = { [weak self] in
      rootViewController.dismiss(animated: true)
    }
    let hostingController = UIHostingController(rootView: optionsView)
    rootViewController.present(hostingController, animated: true)
  }
}
