//
//  Font+Extensions.swift
//  zdoom
//
//  Created by Yoshi Sugawara on 3/13/23.
//

import SwiftUI

extension Font {
  public static var largeTitle: Font {
    Font.custom("PerfectDOSVGA437", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
  }
  
  public static var body: Font {
    Font.custom("PerfectDOSVGA437", size: 20)
  }
  
  public static var selected: Font {
    Font.custom("PerfectDOSVGA437", size: 24)
  }
  
  public static var actionButton: Font {
    Font.custom("PerfectDOSVGA437", size: 32)
  }
  
  public static var small: Font {
    Font.custom("PerfectDOSVGA437", size: 16)
  }
}
