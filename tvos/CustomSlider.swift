//
//  CustomSlider.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 8/6/24.
//

import SwiftUI
import TvOSSlider

struct TvOSSliderSwiftUI: UIViewRepresentable {
  @Binding var value: Float
  let minimumValue: Float
  let maximumValue: Float
  
  
  class Coordinator: NSObject {
    var parent: TvOSSliderSwiftUI
    
    init(parent: TvOSSliderSwiftUI) {
      self.parent = parent
    }
    
    @objc func valueChanged(_ sender: TvOSSlider) {
      parent.value = sender.value
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  func makeUIView(context: Context) -> TvOSSlider {
    let slider = TvOSSlider(frame: .zero)
    slider.minimumValue = minimumValue
    slider.maximumValue = maximumValue
    slider.value = value
    slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
    return slider
  }
  
  func updateUIView(_ uiView: TvOSSlider, context: Context) {
    uiView.value = value
  }
}
