import UIKit

public protocol StringRepresentable {
  static func resolve(value: String) -> Self?
}

extension String: StringRepresentable {
  public static func resolve(value: String) -> String? {
    return value
  }
}

extension CGFloat: StringRepresentable {
  public static func resolve(value: String) -> CGFloat? {
    return value.floatValue
  }
}

extension FlexDirection: StringRepresentable {
  public static func resolve(value: String) -> FlexDirection? {
    switch value {
    case "row":
      return .Row
    case "column":
      return .Column
    default:
      return nil
    }
  }
}

extension String {
  var intValue: Int? {
    let formatter = NSNumberFormatter()
    return formatter.numberFromString(self)?.integerValue
  }

  var floatValue: CGFloat? {
    let formatter = NSNumberFormatter()
    if let float = formatter.numberFromString(self)?.floatValue {
      return CGFloat(float)
    }
    return nil
  }
}