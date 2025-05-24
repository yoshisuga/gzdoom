//
//  FadingTextView.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 5/23/25.
//

import SwiftUI

struct FadingTextView: View {
  let texts: [String]
  
  @State private var currentIndex = 0
  @State private var opacity: Double = 1.0
  
  var body: some View {
    ColoredText("\(texts[currentIndex])")
      .font(.body)
      .multilineTextAlignment(.center)
      .opacity(opacity)
      .onAppear {
        startTextCycle()
      }
  }
  
  private func startTextCycle() {
    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
      withAnimation(.easeInOut(duration: 0.5)) {
        opacity = 0.0
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        currentIndex = (currentIndex + 1) % texts.count
        
        withAnimation(.easeInOut(duration: 0.5)) {
          opacity = 1.0
        }
      }
    }
  }
}
