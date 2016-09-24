//
//  Validation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import UIKit
import CSSLayout

public extension Dictionary {
  func get<T>(_ key: Key) -> T? {
    return self[key] as? T
  }

  func get<T>(_ key: Key, defaultValue: T) -> T {
    return get(key) ?? defaultValue
  }

  func color(_ key: Key) -> UIColor? {
    let value = self[key]
    if let value = value as? UIColor {
      return value
    }
    guard let stringValue = value as? String else {
      return nil
    }
    var sanitized = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if sanitized.hasPrefix("#") {
      sanitized = sanitized.substring(from: sanitized.index(after: sanitized.startIndex))
    }

    var rgbValue: UInt32 = 0
    Scanner(string: sanitized).scanHexInt32(&rgbValue)

    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }

  func image(_ key: Key) -> UIImage? {
    let value = self[key]
    if let value = value as? UIImage {
      return value
    }
    guard let stringValue = value as? String else {
      return nil
    }
    return UIImage(named: stringValue)
  }

  func cast<T: StringRepresentable>(_ key: Key) -> T? {
    let value = self[key]
    if let value = value as? T {
      return value
    }
    if let value = value as? String {
      return T.fromString(value)
    }
    return nil
  }
}

public protocol StringRepresentable {
  static func fromString(_ value: String) -> Self?
}

extension Float: StringRepresentable {
  public static func fromString(_ value: String) -> Float? {
    return NumberFormatter().number(from: value)?.floatValue
  }
}

extension CGFloat: StringRepresentable {
  public static func fromString(_ value: String) -> CGFloat? {
    guard let floatValue = Float.fromString(value) else {
      return nil
    }
    return CGFloat(floatValue)
  }
}

extension Int: StringRepresentable {
  public static func fromString(_ value: String) -> Int? {
    return NumberFormatter().number(from: value)?.intValue
  }
}

extension String: StringRepresentable {
  public static func fromString(_ value: String) -> String? {
    return value
  }
}

extension Bool: StringRepresentable {
  public static func fromString(_ value: String) -> Bool? {
    if value == "true" {
      return true
    }
    if value == "false" {
      return false
    }
    return nil
  }
}

extension URL: StringRepresentable {
  public static func fromString(_ value: String) -> URL? {
    return URL(string: value)
  }
}

extension Selector: StringRepresentable {
  public static func fromString(_ value: String) -> Selector? {
    return Selector(value)
  }
}

extension CSSFlexDirection: StringRepresentable {
  public static func fromString(_ value: String) -> CSSFlexDirection? {
    switch value {
    case "row":
      return CSSFlexDirectionRow
    case "column":
      return CSSFlexDirectionColumn
    default:
      fatalError("Unknown direction value")
    }
  }
}

extension CSSDirection: StringRepresentable {
  public static func fromString(_ value: String) -> CSSDirection? {
    switch value {
    case "inherit":
      return CSSDirectionInherit
    case "ltr":
      return CSSDirectionLTR
    case "rtl":
      return CSSDirectionRTL
    default:
      fatalError("Unknown direction value")
    }
  }
}

extension CSSPositionType: StringRepresentable {
  public static func fromString(_ value: String) -> CSSPositionType? {
    switch value {
    case "relative":
      return CSSPositionTypeRelative
    case "absolute":
      return CSSPositionTypeAbsolute
    default:
      fatalError("Unknown position value")
    }
  }
}

extension CSSWrapType: StringRepresentable {
  public static func fromString(_ value: String) -> CSSWrapType? {
    switch value {
    case "nowrap":
      return CSSWrapTypeNoWrap
    case "wrap":
      return CSSWrapTypeWrap
    default:
      fatalError("Unknown wrap value")
    }
  }
}

extension CSSOverflow: StringRepresentable {
  public static func fromString(_ value: String) -> CSSOverflow? {
    switch value {
    case "visible":
      return CSSOverflowVisible
    case "hidden":
      return CSSOverflowHidden
    default:
      fatalError("Unknown overflow value")
    }
  }
}

extension CSSJustify: StringRepresentable {
  public static func fromString(_ value: String) -> CSSJustify? {
    switch value {
    case "flexStart":
      return CSSJustifyFlexStart
    case "center":
      return CSSJustifyCenter
    case "flexEnd":
      return CSSJustifyFlexEnd
    case "spaceBetween":
      return CSSJustifySpaceBetween
    case "spaceAround":
      return CSSJustifySpaceAround
    default:
      fatalError("Unknown justification value")
    }
  }
}

extension CSSAlign: StringRepresentable {
  public static func fromString(_ value: String) -> CSSAlign? {
    switch value {
    case "flexStart":
      return CSSAlignFlexStart
    case "center":
      return CSSAlignCenter
    case "flexEnd":
      return CSSAlignFlexEnd
    case "stretch":
      return CSSAlignStretch
    case "auto":
      return CSSAlignAuto
    default:
      fatalError("Unknown childAlignment value")
    }
  }
}

extension UIViewContentMode: StringRepresentable {
  public static func fromString(_ value: String) -> UIViewContentMode? {
    switch value {
    case "scaleToFill":
      return .scaleToFill
    case "scaleAspectFit":
      return .scaleAspectFit
    case "scaleAspectFill":
      return .scaleAspectFill
    default:
      fatalError("Unhandled value")
    }
  }
}

extension NSTextAlignment: StringRepresentable {
  public static func fromString(_ value: String) -> NSTextAlignment? {
    switch value {
    case "left":
      return .left
    case "center":
      return .center
    case "right":
      return .right
    case "justified":
      return .justified
    case "natural":
      return .natural
    default:
      fatalError("Unhandled value")
    }
  }
}

extension NSLineBreakMode: StringRepresentable {
  public static func fromString(_ value: String) -> NSLineBreakMode? {
    switch value {
    case "byWordWrapping":
      return .byWordWrapping
    case "byCharWrapping":
      return .byCharWrapping
    case "byClipping":
      return .byClipping
    case "byTruncatingHead":
      return .byTruncatingHead
    case "byTruncatingTail":
      return .byTruncatingTail
    case "byTruncatingMiddle":
      return .byTruncatingMiddle
    default:
      fatalError("Unhandled value")
    }
  }
}
