import UIKit

public protocol Model {
  func value<T>(forKey key: String) -> T?
  func value<T>(forKeyPath keyPath: String) -> T?
  subscript (key : String) -> Any? { get }
}

public extension Model {
  func value<T>(forKey key: String) -> T? {
    var currentMirror: Mirror? = Mirror(reflecting: self)
    while var mirror = currentMirror {
      for child in mirror.children {
        if keysEqual(child.label, key: key) {
          return unwrapAny(child.value) as? T
        }
      }
      currentMirror = mirror.superclassMirror
    }
    return nil
  }

  func value<T>(forKeyPath keyPath: String) -> T? {
    var currentMirror: Mirror? = Mirror(reflecting: self)
    while var mirror = currentMirror {
      var keys = keyPath.components(separatedBy: ".")
      for key in keys {
        for var child in mirror.children {
          if keysEqual(child.label, key: key) {
            if keysEqual(child.label, key: keys.last) {
              return child.value as? T
            } else {
              mirror = Mirror(reflecting: unwrapAny(child.value))
              break
            }
          }
        }
      }
      currentMirror = mirror.superclassMirror
    }

    return nil
  }

  subscript(key: String) -> Any? {
    get {
      return self.value(forKeyPath: key)
    }
  }

  private func keysEqual(_ childLabel: String?, key: String?) -> Bool {
    return childLabel?.replacingOccurrences(of: ".storage", with: "") == key
  }

  private func unwrapAny(_ val: Any) -> Any {
    let mirror = Mirror(reflecting: val)
    if mirror.displayStyle == .optional {
      for child in mirror.children {
        if child.label == "some" {
          return child.value
        }
      }
    }
    return val
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
