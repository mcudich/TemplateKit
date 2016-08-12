import UIKit
import SwiftBox

public class BoxNode: ViewNode<BoxView> {
  private lazy var children = [Node]()

  override init() {
    super.init()
  }
}

extension BoxNode: ContainerNode {
  public func add(child: Node) {
    children.append(child)

    guard let boxView = view as? BoxView else { return }

    boxView.add(child.view)
  }
}

public class BoxView: View {
  public static var propertyTypes: [String : Validator] {
    return [
      "flexDirection": Validation.flexDirection()
    ]
  }

  public weak var propertyProvider: PropertyProvider?

  public var frame: CGRect {
    let resolve: (CGFloat? -> CGFloat) = { value in
      if let value = value where !isnan(value) {
        return value
      }
      return FlexNode.Undefined
    }

    let x: CGFloat? = propertyProvider?.get("x")
    let y: CGFloat? = propertyProvider?.get("y")
    let width: CGFloat? = propertyProvider?.get("width")
    let height: CGFloat? = propertyProvider?.get("height")

    return CGRect(x: resolve(x), y: resolve(y), width: resolve(width), height: resolve(height))
  }

  public var calculatedFrame: CGRect?

  public var flexDirection: FlexDirection? {
    return propertyProvider?.get("flexDirection")
  }

  public var flex: CGFloat? {
    return propertyProvider?.get("flex")
  }

  private lazy var renderedView = UIView()
  private lazy var children = [View]()

  public required init() {}

  func add(view: View) {
    children.append(view)
  }

  public func render() -> UIView {
    // TODO(mcudich): Diff and be smarter about touching the UI tree here.
    for child in children {
      let childView = child.render()
      childView.frame = child.calculatedFrame ?? CGRectZero
      renderedView.addSubview(childView)
    }

    return renderedView
  }

  public func sizeThatFits(size: CGSize) -> CGSize {
    let layout = flexNode.layout(maxWidth: size.width)

    applyLayout(layout)

    return layout.frame.size
  }

  private func applyLayout(layout: Layout) {
    for (index, layout) in layout.children.enumerate() {
      let child = children[index]
      child.calculatedFrame = layout.frame
      if let child = child as? BoxView {
        child.applyLayout(layout)
      }
    }
  }
}

public enum FlexDirection {
  case Row
  case Column

  var value: SwiftBox.Direction {
    switch self {
    case .Column:
      return SwiftBox.Direction.Column
    case .Row:
      return SwiftBox.Direction.Row
    }
  }
}

typealias FlexNode = SwiftBox.Node

extension View {
  var flexSize: CGSize {
    return CGSize(width: frame.width ?? FlexNode.Undefined, height: frame.height ?? FlexNode.Undefined)
  }
}

protocol FlexNodeProvider {
  var flexNode: FlexNode { get }
}

extension BoxView: FlexNodeProvider {
  var flexNode: FlexNode {
    let flexNodes = children.map { ($0 as! FlexNodeProvider).flexNode }
    return FlexNode(size: flexSize, children: flexNodes, direction: flexDirection?.value ?? .Row, margin: Edges(), padding: Edges(), wrap: false, justification: .FlexStart, selfAlignment: .Auto, childAlignment: .Stretch, flex: flex ?? 0)
  }
}

extension TextView: FlexNodeProvider {
  var flexNode: FlexNode {
    let measure = { [weak self] width in
      return self?.sizeThatFits(CGSize(width: width, height: CGFloat.max)) ?? CGSizeZero
    }
    return FlexNode(measure: measure)
  }
}
