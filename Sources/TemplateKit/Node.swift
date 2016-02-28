import UIKit

public enum FlexDirection {
  case Row
  case Column
}

public class Node {
  public var id: String?
  public var x: CGFloat?
  public var y: CGFloat?
  public var width: CGFloat?
  public var height: CGFloat?
  public var flex: CGFloat?
  public var flexDirection: FlexDirection?

  public var model: Model? {
    didSet {
      applyProperties()
    }
  }

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

  lazy var view: UIView = { [unowned self] in
    return self.createView()
  }()

  let properties: [String: String]

  public required init(properties: [String: String] = [:]) {
    self.properties = properties
    applyProperties()
  }

  public func render() -> UIView {
    applyPropertiesToView()
    return view
  }

  public func measure(size: CGSize) -> CGSize {
    return CGSizeZero
  }

  func applyPropertiesToView() {
    view.frame = frame
  }

  func applyProperties() {
    for (key, value) in properties {
      switch key {
      case "x":
        x = resolve(value)
      case "y":
        y = resolve(value)
      case "width":
        width = resolve(value)
      case "height":
        height = resolve(value)
      case "flex":
        flex = resolve(value)
      case "flexDirection":
        flexDirection = resolve(value)
      default:
      break
      }
    }
  }

  func resolve<T: StringRepresentable>(value: String) -> T? {
    if value.hasPrefix("$") {
      let startIndex = value.startIndex.advancedBy(1);
      let key = value.substringFromIndex(startIndex);

      return model?.valueForKey(key) as? T
    }

    return T.resolve(value)
  }

  func createView() -> UIView {
    return UIView()
  }
}
