//
//  Interpolatable.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Interpolatable {
  static func interpolate(_ from: Self, _ to: Self, _ progress: Double) -> Self
}

extension CGFloat: Interpolatable {
  public static func interpolate(_ from: CGFloat, _ to: CGFloat, _ progress: Double) -> CGFloat {
    return (from + CGFloat(progress) * (to - from))
  }
}

extension Float: Interpolatable {
  public static func interpolate(_ from: Float, _ to: Float, _ progress: Double) -> Float {
    return (from + Float(progress) * (to - from))
  }
}

extension UIColor: Interpolatable {
  public static func interpolate(_ from: UIColor, _ to: UIColor, _ progress: Double) -> Self {
    var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
    from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)

    var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
    to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

    let red = CGFloat.interpolate(fromRed, toRed, progress)
    let green = CGFloat.interpolate(fromGreen, toGreen, progress)
    let blue = CGFloat.interpolate(fromBlue, toBlue, progress)
    let alpha = CGFloat.interpolate(fromAlpha, toAlpha, progress)

    return self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
