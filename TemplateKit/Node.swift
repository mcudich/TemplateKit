import UIKit

public enum FlexDirection {
  case Row
  case Column
}

public protocol NodeView {
  var frame: CGRect { set get }

  init()
}

//extension UIView: NodeView {
//}

public protocol Node: class {
  var id: String? { set get }
  var x: CGFloat? { set get }
  var y: CGFloat? { set get }
  var width: CGFloat? { set get }
  var height: CGFloat? { set get }
  var model: Model? { set get }
  var frame: CGRect { set get }
  var view: NodeView { set get }
  var properties: [String: Any] { set get }

  func render() -> NodeView
  func sizeThatFits(size: CGSize) -> CGSize
  func sizeToFit(size: CGSize)
}

extension Node {
  public var frame: CGRect {
    get {
      let resolve: (CGFloat? -> CGFloat) = { value in
        if let value = value where !isnan(value) {
          return value
        }
        return 0
      }
      return CGRect(x: resolve(x), y: resolve(y), width: resolve(width), height: resolve(height))
    }
    set (newValue) {
      x = newValue.minX
      y = newValue.minY
      width = newValue.width
      height = newValue.height
    }
  }

  public var x: CGFloat? {
    set {
      properties["x"] = x
    }
    get {
      return properties["x"] as? CGFloat
    }
  }

  public var y: CGFloat? {
    set {
      properties["y"] = x
    }
    get {
      return properties["y"] as? CGFloat
    }
  }

  public var width: CGFloat? {
    set {
      properties["width"] = x
    }
    get {
      return properties["width"] as? CGFloat
    }
  }

  public var height: CGFloat? {
    set {
      properties["height"] = x
    }
    get {
      return properties["height"] as? CGFloat
    }
  }

  public func render() -> NodeView {
    view.frame = frame

    return view
  }

  public func sizeThatFits(size: CGSize) -> CGSize {
    return size
  }

  public func sizeToFit(size: CGSize) {
    frame.size = size
  }

  public func invalidate() {
    for (key, value) in properties {
      properties[key] = resolve(value)
    }
  }

  func resolve(value: Any) -> Any? {
    guard let expression = value as? String where expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.startIndex.advancedBy(1);
    let key = expression.substringFromIndex(startIndex);
    return model?.valueForKey(key)
  }
}

public class ViewNode<V: NodeView>: Node {
  public var id: String?
  public var properties: [String: Any]
  public var model: Model?

  public lazy var view: NodeView = V()

  public required init(properties: [String: String] = [:]) {
    self.properties = properties
  }
}
