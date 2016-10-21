//
//  Interpolatable.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Interpolatable {
  static func interpolate(_ currentTime: TimeInterval, _ from: Self, _ to: Self, _ duration: TimeInterval, _ ease: EasingFunction) -> Self
}

// See http://gizma.com/easing/.
public enum EasingFunction {
  case linear
  case quadraticEaseIn
  case quadraticEaseOut

  func interpolate(_ currentTime: TimeInterval, _ from: Float, _ to: Float, _ duration: TimeInterval) -> Float {
    let delta = to - from
    let progress = Float(currentTime / duration)

    switch self {
    case .linear:
      return delta * progress + from
    case .quadraticEaseIn:
      return (delta * progress * progress) + from
    case .quadraticEaseOut:
      return -delta * progress * (progress - 2) + from
    }
  }
}

extension CGFloat: Interpolatable {
  public static func interpolate(_ currentTime: TimeInterval, _ from: CGFloat, _ to: CGFloat, _ duration: TimeInterval, _ ease: EasingFunction) -> CGFloat {
    return CGFloat(ease.interpolate(currentTime, Float(from), Float(to), duration))
  }
}

extension Float: Interpolatable {
  public static func interpolate(_ currentTime: TimeInterval, _ from: Float, _ to: Float, _ duration: TimeInterval, _ ease: EasingFunction) -> Float {
    return ease.interpolate(currentTime, from, to, duration)
  }
}

extension UIColor: Interpolatable {
  public static func interpolate(_ currentTime: TimeInterval, _ from: UIColor, _ to: UIColor, _ duration: TimeInterval, _ ease: EasingFunction) -> Self {
    var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
    from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)

    var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
    to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

    let red = ease.interpolate(currentTime, Float(fromRed), Float(toRed), duration)
    let green = ease.interpolate(currentTime, Float(fromGreen), Float(toGreen), duration)
    let blue = ease.interpolate(currentTime, Float(fromBlue), Float(toBlue), duration)
    let alpha = ease.interpolate(currentTime, Float(fromAlpha), Float(toAlpha), duration)

    return self.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
  }
}
