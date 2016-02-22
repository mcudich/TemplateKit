import UIKit
import SwiftBox

public class Node {
  private lazy var view = UIView()

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

  public required init() {}

  public func render() -> UIView {
    return view
  }

  public func measure(size: CGSize) -> CGSize {
    return CGSizeZero
  }
}