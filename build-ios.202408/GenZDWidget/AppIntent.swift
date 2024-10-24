//
//  AppIntent.swift
//  GZDoom
//
//  Created by Yoshi Sugawara on 10/23/24.
//

import AppIntents

@available(iOS 16, *)
struct PerformAction: AppIntent {
  static let title: LocalizedStringResource = "Perform action"


 func perform() async throws -> some IntentResult {
  // Code that performs the action...
  return .result()
 }
}

@available(iOS 16, *)
struct LaunchAppIntent: OpenIntent {
  static var title: LocalizedStringResource = "Launch App"
  @Parameter(title: "Target")
  var target: LaunchAppEnum
}

@available(iOS 16, *)
enum LaunchAppEnum: String, AppEnum {
    case launch

    static var typeDisplayRepresentation = TypeDisplayRepresentation("GenZD")
    static var caseDisplayRepresentations = [
        LaunchAppEnum.launch : DisplayRepresentation("Launch")
    ]
}
