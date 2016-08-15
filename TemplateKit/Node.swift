import UIKit

public protocol PropertyTypeProvider {
  static var propertyTypes: [String: ValidationType] { get }
}

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol Node: Renderable, PropertyProvider, PropertyTypeProvider {
  var model: Model? { set get }
  var view: View { set get }
  var properties: [String: Any]? { set get }
}

extension Node {
  public func get<T>(_ key: String) -> T? {
    return resolve(properties?[key]) as? T
  }

  func resolve(_ value: Any) -> Any {
    guard let expression = value as? String, expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.characters.index(expression.startIndex, offsetBy: 1);
    let key = expression.substring(from: startIndex);
    return model?.value(forKey: key)
  }
}
