import UIKit

extension String {
  var int: Int? {
    let formatter = NumberFormatter()
    return formatter.number(from: self)?.intValue
  }

  var float: CGFloat? {
    let formatter = NumberFormatter()
    if let float = formatter.number(from: self)?.floatValue {
      return CGFloat(float)
    }
    return nil
  }

  var url: URL? {
    return URL(string: self)
  }
}
