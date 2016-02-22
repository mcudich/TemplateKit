import UIKit
import SwiftBox

public class Node {
  private lazy var view = UIView()

  public var x: CGFloat?
  public var y: CGFloat?
  public var width: CGFloat?
  public var height: CGFloat?
  public var flex: CGFloat?

  public var frame: CGRect {
    get {
      return CGRect(x: x ?? 0, y: y ?? 0, width: width ?? 0, height: height ?? 0)
    }
    set {
      x = frame.minX
      y = frame.minY
      width = frame.width
      height = frame.height
    }
  }

  public init() {}

  public func render() -> UIView {
    return view
  }

  public func measure(size: CGSize) -> CGSize {
    return CGSizeZero
  }
}