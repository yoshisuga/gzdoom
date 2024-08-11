//
//  HelpView.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/10/23.
//

import SwiftUI

struct HelpSheetView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.openURL) var openURL
  
  enum ViewMode {
    case help, whatsNew
  }
  
  @State var viewMode = ViewMode.help
  
  @State var helpContents: String.LocalizationValue = ""
  
  var body: some View {
    VStack {
      ZStack {
        if viewMode == .whatsNew {
          Text("What's New")
        } else {
          Text("GenZD")
        }
        HStack {
          Button {
            if viewMode == .help {
              viewMode = .whatsNew
            } else {
              viewMode = .help
            }
          } label: {
            if viewMode == .help {
              Text("What's New?")
            } else {
              Text("Help")
            }
          }.buttonStyle(.bordered)
          Spacer()
          Button("Done") {
            dismiss()
          }.buttonStyle(.bordered)
        }
      }
      ScrollView {
        VStack(spacing: 4) {
          ColoredText(loadContent()).font(.body).foregroundColor(.gray).lineSpacing(4)
        }.padding()
      }
    }.padding(.top)
//      .onAppear {
//        guard let fileURL = viewMode == .whatsNew ?
//                Bundle.main.url(forResource: "whats-new", withExtension: "md") :
//                  Bundle.main.url(forResource: "ios-help", withExtension: "md") else { return }
//        let string = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? "Error loading help file 😖"
//        helpContents = String.LocalizationValue(string)
//      }
  }
  
  private func loadContent() -> String.LocalizationValue {
    guard let fileURL = viewMode == .whatsNew ?
            Bundle.main.url(forResource: "whats-new", withExtension: "md") :
              Bundle.main.url(forResource: "ios-help", withExtension: "md") else { return "" }
    let string = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? "Error loading help file 😖"
    return String.LocalizationValue(string)
  }
}

enum ColoredAttribute: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
  enum Value: String, Codable, Hashable {
    case red, orange, yellow, green, mint, teal, cyan, blue
    case indigo, purple, pink, brown, gray, white
  }
  
  static var name: String = "colored"
}

extension AttributeScopes {
  struct GZDoomAppAttributes: AttributeScope {
    let colored: ColoredAttribute
  }
  var gzDoomApp: GZDoomAppAttributes.Type { GZDoomAppAttributes.self }
}

extension AttributeDynamicLookup {
  subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.GZDoomAppAttributes, T>) -> T {
    self[T.self]
  }
}

struct ColoredText: View {
  private var attributedString: AttributedString
  private var font: Font = .body
  private static let colors: [ColoredAttribute.Value: Color] = [
    .red: .red,
    .orange: .orange,
    .yellow: .yellow,
    .green: .green,
    .mint: .mint,
    .teal: .teal,
    .cyan: .cyan,
    .blue: .blue,
    .indigo: .indigo,
    .purple: .purple,
    .pink: .pink,
    .brown: .brown,
    .gray: .gray,
    .white: .white
  ]
  
  var body: some View {
    Text(attributedString).font(font)
  }
  
  init(withAttributedString attributedString: AttributedString) {
    self.attributedString = ColoredText.annotateColors(from: attributedString)
  }
  
  init(_ localizedKey: String.LocalizationValue) {
    attributedString = ColoredText.annotateColors(from: AttributedString(localized: localizedKey, including: \.gzDoomApp))
  }
  
  func font(_ font: Font) -> ColoredText {
      var selfText = self
      selfText.font = font
      return selfText
  }
  
  private static func annotateColors(from source: AttributedString) -> AttributedString {
    var attrString = source
    for run in attrString.runs {
      guard let colored = run.colored else { continue }
      let color = colors[colored]!
      attrString[run.range].foregroundColor = color
    }
    return attrString
  }
}
