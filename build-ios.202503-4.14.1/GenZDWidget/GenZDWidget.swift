//
//  GenZDWidget.swift
//  GenZDWidget
//
//  Created by Yoshi Sugawara on 10/23/24.
//

import WidgetKit
import SwiftUI

struct DummyProvider: TimelineProvider {
   func getSnapshot(in context: Context, completion: @escaping (DummyEntry) -> Void) {
      completion(DummyEntry())
   }

   func getTimeline(in context: Context, completion: @escaping (Timeline<DummyEntry>) -> Void) {
      completion(Timeline(entries: [DummyEntry()], policy: .never))
   }
   
   func placeholder(in context: Context) -> DummyEntry {
      DummyEntry()
   }
}

struct DummyEntry: TimelineEntry {
   let date = Date()
}

struct GenZDImageView : View {
    var body: some View {
#if swift(>=5.9)
       if #available(iOSApplicationExtension 17.0, *) {
          ZStack {
             AccessoryWidgetBackground()
             Image("logo")
          }
          .containerBackground(for: .widget) {}
       } else {
          ZStack {
             AccessoryWidgetBackground()
             Image("logo")
          }
       }
#else
       ZStack {
          AccessoryWidgetBackground()
          Image("logo")
       }
#endif
    }
}

struct GenZDWidget: Widget {
    let kind: String = "GenZDWidget"

    var body: some WidgetConfiguration {
       if #available(iOSApplicationExtension 16.0, *) {
          return StaticConfiguration(kind: kind, provider: DummyProvider()) { _ in
            GenZDImageView()
          }
          .configurationDisplayName("Icon")
          .description("Launch GenZD.")
          .supportedFamilies([.accessoryCircular, .systemSmall])
       } else {
          return EmptyWidgetConfiguration()
       }
    }
}

@available(iOS 18, *)
struct GenZDControlCenterWidget: ControlWidget {
  let kind: String = "GenZDControlCenterWidget"
  
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: kind) {
      ControlWidgetButton(action: LaunchAppIntent()) {
        Image("genzd.SFSymbol")
          .imageScale(.large)
      }
    }
    .displayName("GenZD")
    .description("Launch GenZD.")
  }
}

@main
struct GenZDWidgetBundle: WidgetBundle {
  var body: some Widget {
    GenZDWidget()
    if #available(iOS 18, *) {
      GenZDControlCenterWidget()
    }
  }
}

#Preview(as: .systemSmall) {
    GenZDWidget()
} timeline: {
  DummyEntry()
}
