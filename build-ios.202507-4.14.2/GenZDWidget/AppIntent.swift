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
struct LaunchAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Launch App"
    static var description = IntentDescription("Opens the GenZD app")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

