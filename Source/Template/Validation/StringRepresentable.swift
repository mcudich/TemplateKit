import UIKit

protocol StringRepresentable {
  static func fromString(_ value: String) -> Self
}

extension Float: StringRepresentable {
  static func fromString(_ value: String) -> Float {
    return 1
  }
}

extension String {
  var integer: Int? {
    return NumberFormatter().number(from: self)?.intValue
  }

  var float: Float? {
    return NumberFormatter().number(from: self)?.floatValue
  }

  var boolean: Bool? {
    if self == "true" {
      return true
    }
    if self == "false" {
      return false
    }
    return nil
  }

  var url: URL? {
    return URL(string: self)
  }

  var color: UIColor? {
    var sanitized = trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

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
}
