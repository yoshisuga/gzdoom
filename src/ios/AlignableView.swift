//
//  AlignableView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 8/17/24.
//

import UIKit

class AlignableView: UIView {
  var initialCenter: CGPoint = .zero
  private var horizontalGuide = UIView()
  private var verticalGuide = UIView()
  private var alignmentThreshold: CGFloat = 10.0

  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func showGuides() {
    guard let superview = superview else { return }
    horizontalGuide = DottedLineView(frame: CGRect(x: 0, y: center.y - 1, width: superview.bounds.width, height: 2))
    superview.addSubview(horizontalGuide)

    let vline = DottedLineView(frame: CGRect(x: center.x - 1, y: 0, width: 2, height: superview.bounds.height))
    vline.orientation = .vertical
    verticalGuide = vline
    superview.addSubview(verticalGuide)
  }
  
  func hideGuides() {
    horizontalGuide.removeFromSuperview()
    verticalGuide.removeFromSuperview()
  }
  
  func updateGuides(using subviews: [UIView]) {
    var horizontalAligned = false
    var verticalAligned = false

    for subview in subviews where subview !== self {
        if abs(center.y - subview.center.y) < alignmentThreshold {
            horizontalAligned = true
            horizontalGuide.frame.origin.y = subview.center.y - 1
        }

        if abs(center.x - subview.center.x) < alignmentThreshold {
            verticalAligned = true
            verticalGuide.frame.origin.x = subview.center.x - 1
        }
    }

    horizontalGuide.isHidden = !horizontalAligned
    verticalGuide.isHidden = !verticalAligned
  }
  
  func snapToNearestGuide(using subviews: [UIView]) {
      for subview in subviews where subview !== self {
          if abs(center.y - subview.center.y) < alignmentThreshold {
              center.y = subview.center.y
          }

          if abs(center.x - subview.center.x) < alignmentThreshold {
              center.x = subview.center.x
          }
      }
  }
}

class DottedLineView: UIView {
    enum Orientation {
        case horizontal
        case vertical
    }
    
    var orientation: Orientation = .horizontal {
        didSet {
            setup()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() } // Remove previous layers
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [2, 3] // Dotted pattern
        
        let path = CGMutablePath()
        if orientation == .horizontal {
            path.addLines(between: [CGPoint(x: 0, y: bounds.midY), CGPoint(x: bounds.width, y: bounds.midY)])
        } else {
            path.addLines(between: [CGPoint(x: bounds.midX, y: 0), CGPoint(x: bounds.midX, y: bounds.height)])
        }
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
        
        // Animation
        let animation = CABasicAnimation(keyPath: "lineDashPhase")
        animation.fromValue = 0
        animation.toValue = shapeLayer.lineDashPattern?.reduce(0) { $0 + $1.intValue } ?? 0
        animation.duration = 1
        animation.repeatCount = .infinity
        shapeLayer.add(animation, forKey: "lineDashPhase")
    }
}


