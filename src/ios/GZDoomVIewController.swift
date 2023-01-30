//
//  GZDoomVIewController.swift
//  zdoom_native
//
//  Created by Yoshi Sugawara on 11/14/21.
//

import UIKit

extension IOSUtils {
    @objc func getView() -> GZDoomView? {
        guard let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
              let rootViewController = keyWindow.rootViewController,
              let doomVC = rootViewController as? GZDoomViewController else {
                  return nil
              }
        return doomVC.metalView
    }
}

@objc class GZDoomView: UIView {
    static override var layerClass: AnyClass { CAMetalLayer.self }
}

class GZDoomViewController: UIViewController {
    lazy var metalView: GZDoomView = {
        let view = GZDoomView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(metalView)
        metalView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        metalView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        metalView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let utils = IOSUtils.shared()!
        let keyboard = EmulatorKeyboardController(leftKeyboardModel: utils.leftKeyboardModel, rightKeyboardModel: utils.rightKeyboardModel)
        keyboard.rightKeyboardModel.delegate = utils as? EmulatorKeyboardKeyPressedDelegate
        keyboard.leftKeyboardModel.delegate = utils as? EmulatorKeyboardKeyPressedDelegate
        addChild(keyboard)
        let keyboardView = keyboard.view!
        view.addSubview(keyboardView)
        keyboard.didMove(toParent: self)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            IOSUtils.shared().doMain()
        }        
    }
}
