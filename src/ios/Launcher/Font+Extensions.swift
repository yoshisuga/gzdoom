//
//  Font+Extensions.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import SwiftUI

extension Font {
  public static var largeTitle: Font {
    #if os(iOS)
    Font.custom("PerfectDOSVGA437", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    #else
    Font.custom("PerfectDOSVGA437", size: UIFont.preferredFont(forTextStyle: .title1).pointSize)
    #endif
  }
  
  public static var body: Font {
    #if os(tvOS)
    Font.custom("PerfectDOSVGA437", size: 40)
    #else
    Font.custom("PerfectDOSVGA437", size: 20)
    #endif
  }
  
  public static var selected: Font {
    Font.custom("PerfectDOSVGA437", size: 24)
  }
  
  public static var actionButton: Font {
    #if os(tvOS)
    Font.custom("PerfectDOSVGA437", size: 56)
    #else
    Font.custom("PerfectDOSVGA437", size: 28)
    #endif
  }
  
  public static var small: Font {
    #if os(tvOS)
    Font.custom("PerfectDOSVGA437", size: 32)
    #else
    Font.custom("PerfectDOSVGA437", size: 16)
    #endif
  }
}
