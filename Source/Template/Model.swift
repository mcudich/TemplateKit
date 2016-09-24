import UIKit

public protocol Model {
  func value<T>(forKey key: String) -> T?
  func value<T>(forKeyPath keyPath: String) -> T?
  subscript (key : String) -> Any? { get }
}

public extension Model {
  func value<T>(forKey key: String) -> T? {
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if child.label == key {
        return child.value as? T
      }
    }
    return nil
  }

  func value<T>(forKeyPath keyPath: String) -> T? {
    var keys = keyPath.components(separatedBy: ".")
    var mirror = Mirror(reflecting: self)

    for key in keys {
      for child in mirror.children {
        if child.label == key {
          if child.label == keys.last {
            return child.value as? T
          }
          else {
            mirror = Mirror(reflecting: child.value)
          }
        }
      }
    }
    return nil
  }

  /// Returns the value for the property identified by a given key.
  subscript (key : String) -> Any? {
    get {
      return self.value(forKeyPath: key)
    }
  }
}

extension Dictionary: Model {}

extension Dictionary {
  public func value<T>(forKey key: String) -> T? {
    let separator = "."
    var keyPath = key.components(separatedBy: separator)

    guard let stringKey = keyPath.removeFirst() as? Key else {
      fatalError("Attempting to fetch value from dictionary without string keys")
    }

    let rootValue = self[stringKey] as? T

    if keyPath.count > 0, let modelValue = rootValue as? Model {
      return modelValue.value(forKeyPath: keyPath.joined(separator: separator))
    }
    return rootValue
  }
}
