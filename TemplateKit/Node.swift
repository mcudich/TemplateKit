import UIKit

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol Node: Renderable, PropertyProvider {
  var view: View { get }
  var properties: [String: Any]? { get }

  init(properties: [String: Any])
}

extension Node {
  public func get<T>(_ key: String) -> T? {
    return properties?[key] as? T
  }
}
