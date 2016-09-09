import UIKit

public protocol Model {
  func value(forKey key: String) -> Any?
}

public extension Model {
  func value(forKey key: String) -> Any? {
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if child.label == key {
        let value = unwrapAny(val: child.value);
        // CGFloats will be treated as either Float or Double by the reflection API.
        if let floatValue = value as? Float {
          return CGFloat(floatValue)
        }
        if let doubleValue = value as? Double {
          return CGFloat(doubleValue)
        }
        return value
      }
    }
    return nil
  }

  private func unwrapAny(val: Any) -> Any {
    let mirror = Mirror(reflecting: val)
    if mirror.displayStyle == .optional {
      for child in mirror.children {
        if child.label == "Some" {
          return child.value
        }
      }
    }
    return val
  }
}

extension Dictionary: Model {}

extension Dictionary {
  public func value(forKey key: String) -> Any? {
    let separator = "."
    var keyPath = key.components(separatedBy: separator)

    guard let stringKey = keyPath.removeFirst() as? Key else {
      fatalError("Attempting to fetch value from dictionary without string keys")
    }

    let rootValue = self[stringKey]

    if keyPath.count > 0, let modelValue = rootValue as? Model {
      return modelValue.value(forKey: keyPath.joined(separator: separator))
    }
    return rootValue
  }
}
