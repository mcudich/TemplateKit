import UIKit

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol Node: Layoutable {
  var properties: [String: Any] { get }
  var key: String? { get }
  var calculatedFrame: CGRect? { get set }

  init(properties: [String: Any])

  func build(completion: (Node) -> Void)
  func render(completion: @escaping (UIView) -> Void)
  // TODO(mcudich): Now that this is mutating, its name is a bit odd. Think of something better.
  mutating func sizeThatFits(_ size: CGSize, completion: (CGSize) -> Void)
  mutating func sizeToFit(_ size: CGSize)
}

public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
  return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

public func ==(lhs: Node, rhs: Node) -> Bool {
  return lhs.properties == rhs.properties && lhs.key == rhs.key
}

extension Node {
  public var key: String? {
    return get("key")
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }

  public func render(completion: @escaping (UIView) -> Void) {
    build { (var root) in
      root.sizeToFit(flexSize)
      DispatchQueue.main.async {
        root.render { view in
          completion(view)
        }
      }
    }
  }

  public mutating func sizeToFit(_ size: CGSize) {
    sizeThatFits(size) { computedSize in
      if calculatedFrame == nil {
        calculatedFrame = CGRect.zero
      }
      calculatedFrame!.size = computedSize
    }
  }
}
