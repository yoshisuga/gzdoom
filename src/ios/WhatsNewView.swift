//
//  WhatsNewView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 7/30/24.
//

import SwiftUI

struct WhatsNewView: View {
  static let userDefaultsKey = "whats-new-viewed"
  
  @State var content: String.LocalizationValue = ""
  
  var closeClosure: (() -> Void)?
  
  var body: some View {
    VStack {
      ScrollView {
        VStack(spacing: 4) {
          ColoredText(content).font(.body).foregroundColor(.gray).lineSpacing(4)
        }.padding()
      }
      Button(action: {
        closeClosure?()
        UserDefaults.standard.setValue(LauncherView.currentVersion, forKey: Self.userDefaultsKey)
      }, label: {
        Text("Close")
      }).buttonStyle(.bordered).foregroundColor(.white).font(.actionButton)
    }.padding(.top).overlay(
      RoundedRectangle(cornerRadius: 15).stroke(.red, lineWidth: 2)
    ).onAppear {
      guard !UserDefaults.standard.bool(forKey: WhatsNewView.userDefaultsKey),
            let url = Bundle.main.url(forResource: "whats-new", withExtension: "md"),
            let whatsNewContent = try? String(contentsOf: url, encoding: .utf8) else {
        return
      }
      content = String.LocalizationValue(whatsNewContent)
    }.background(.black)
  }
}

