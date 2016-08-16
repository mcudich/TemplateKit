import UIKit

public protocol PropertyTypeProvider {
  static var propertyTypes: [String: ValidationType] { get }
}

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol Node: Renderable, PropertyProvider, PropertyTypeProvider {
  var view: View { get }
  var properties: [String: Any]? { set get }
}

extension Node {
  public func get<T>(_ key: String) -> T? {
    return properties?[key] as? T
  }
}
