import UIKit

extension String {
  var int: Int? {
    let formatter = NSNumberFormatter()
    return formatter.numberFromString(self)?.integerValue
  }

  var float: CGFloat? {
    let formatter = NSNumberFormatter()
    if let float = formatter.numberFromString(self)?.floatValue {
      return CGFloat(float)
    }
    return nil
  }

  var url: NSURL? {
    return NSURL(string: self)
  }

  var flexDirection: FlexDirection? {
    switch self {
    case "row":
      return .Row
    case "column":
      return .Column
    default:
      return nil
    }
  }
}