import UIKit

public protocol Node: Renderable {
  var model: Model? { set get }
  var view: View { set get }
  var properties: [String: Any]? { set get }

  static var propertyTypes: [String: Validator] { get }
}

extension Node {
  public func invalidate() {
    guard var properties = properties else { return }
    for (key, value) in properties {
      properties[key] = resolve(value)
    }
  }

  func resolve(_ value: Any) -> Any? {
    guard let expression = value as? String, expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.characters.index(expression.startIndex, offsetBy: 1);
    let key = expression.substring(from: startIndex);
    return model?.value(forKey: key)
  }
}
