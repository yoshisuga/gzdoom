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
    Font.custom("PerfectDOSVGA437", size: 20)
  }
  
  public static var selected: Font {
    Font.custom("PerfectDOSVGA437", size: 24)
  }
  
  public static var actionButton: Font {
    Font.custom("PerfectDOSVGA437", size: 28)
  }
  
  public static var small: Font {
    Font.custom("PerfectDOSVGA437", size: 16)
  }
}
