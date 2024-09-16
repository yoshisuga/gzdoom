//
//  SystemModalManager.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 9/14/24.
//

import Foundation
import UIKit

@objcMembers class SystemModalManager: NSObject {
  static let shared = SystemModalManager()
  
  weak var rootViewController: UIViewController?
  
  var isCancelled = false
  
  var alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
  
  private func isAlertControllerPresented() -> Bool {
      if let rootViewController {
          var currentViewController = rootViewController
          while let presentedViewController = currentViewController.presentedViewController {
              if presentedViewController == alertController {
                  return true
              }
              currentViewController = presentedViewController
          }
      }
      return false
  }

  func showMessage(title: String, message: String) {
    guard let rootViewController else { return }
    let titleFont = [NSAttributedString.Key.font: UIFont(name: "PerfectDOSVGA437", size: 20)!]
    let msgFont = [NSAttributedString.Key.font: UIFont(name: "PerfectDOSVGA437", size: 14)!]
    if !title.isEmpty {
      alertController.setValue(NSMutableAttributedString(string: title, attributes: titleFont), forKey: "attributedTitle")
    }
    alertController.setValue(NSMutableAttributedString(string: message, attributes: msgFont), forKey: "attributedMessage")
    if alertController.actions.count == 0 {
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
        self?.isCancelled = true
      }))
    }
    DispatchQueue.main.async {
      if !self.isAlertControllerPresented() {
        rootViewController.present(self.alertController, animated: true)
      }
    }
  }
  
  func dismiss() {
    alertController.dismiss(animated: true)
    isCancelled = false
  }  
}
