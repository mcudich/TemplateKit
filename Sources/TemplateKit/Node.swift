import UIKit

public enum FlexDirection {
  case Row
  case Column
}

public class Node {
  private lazy var view = UIView()

  public var id: String?
  public var x: CGFloat?
  public var y: CGFloat?
  public var width: CGFloat?
  public var height: CGFloat?
  public var flex: CGFloat?
  public var flexDirection: FlexDirection?

  public var frame: CGRect {
    get {
      return CGRect(x: x ?? 0, y: y ?? 0, width: width ?? 0, height: height ?? 0)
    }
    set (newValue) {
      x = newValue.minX
      y = newValue.minY
      width = newValue.width
      height = newValue.height
    }
  }

  public required init(properties: [String: String] = [:]) {
    applyProperties(properties)
  }

  public func render() -> UIView {
    return view
  }

  public func measure(size: CGSize) -> CGSize {
    return CGSizeZero
  }

  private func applyProperties(properties: [String: String]) {
    for (key, value) in properties {
      switch key {
      case "x":
        if let value = value.floatValue {
          x = CGFloat(value)
        }
      case "y":
        if let value = value.floatValue {
          y = CGFloat(value)
        }
      case "width":
        if let value = value.floatValue {
          width = CGFloat(value)
        }
      case "height":
        if let value = value.floatValue {
          height = CGFloat(value)
        }
      default:
        break
      }
    }
  }
}

extension String {
  var floatValue: Float? {
    if let number = NSNumberFormatter().numberFromString(self) {
      return number.floatValue
    }
    return nil
  }
}