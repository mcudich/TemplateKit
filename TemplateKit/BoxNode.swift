import UIKit
import SwiftBox

extension String {
  var flexDirection: Direction {
    switch self {
    case "row":
      return .row
    case "column":
      return .column
    default:
      fatalError("Unknown direction value")
    }
  }

  var justification: Justification {
    switch self {
    case "flexStart":
      return .flexStart
    case "center":
      return .center
    case "flexEnd":
      return .flexEnd
    case "spaceBetween":
      return .spaceBetween
    case "spaceAround":
      return .spaceAround
    default:
      fatalError("Unknown justification value")
    }
  }

  var selfAlignment: SelfAlignment {
    switch self {
    case "auto":
      return .auto
    case "flexStart":
      return .flexStart
    case "center":
      return .center
    case "flexEnd":
      return .flexEnd
    case "stretch":
      return .stretch
    default:
      fatalError("Unknown selfAlignment value")
    }
  }

  var childAlignment: ChildAlignment {
    switch self {
    case "flexStart":
      return .flexStart
    case "center":
      return .center
    case "flexEnd":
      return .flexEnd
    case "stretch":
      return .stretch
    default:
      fatalError("Unknown childAlignment value")
    }
  }
}

enum FlexboxValidation: String, ValidationType {
  case flexDirection
  case justification
  case selfAlignment
  case childAlignment

  func validate(value: Any?) -> Any? {
    switch self {
    case .flexDirection:
      if value is Direction {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.flexDirection
      }
    case .justification:
      if value is Justification {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.justification
      }
    case .selfAlignment:
      if value is SelfAlignment {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.selfAlignment
      }
    case .childAlignment:
      if value is ChildAlignment {
      return value
      }
      if let stringValue = value as? String {
        return stringValue.childAlignment
      }
    }

    if value != nil {
      fatalError("Unhandled type!")
    }

    return nil
  }
}

public class BoxNode: ViewNode<BoxView> {
  public lazy var children = [Node]()
}

extension BoxNode: ContainerNode {
  public func add(child: Node) {
    children.append(child)

    guard let boxView = view as? BoxView else { return }

    boxView.add(view: child.view)
  }
}

public class BoxView: View {
  public weak var propertyProvider: PropertyProvider?

  public var calculatedFrame: CGRect?

  private lazy var renderedView = UIView()
  fileprivate lazy var children = [View]()

  public required init() {}

  func add(view: View) {
    children.append(view)
  }

  public func render() -> UIView {
    // TODO(mcudich): Diff and be smarter about touching the UI tree here.
    for child in children {
      let childView = child.render()
      childView.frame = child.calculatedFrame ?? CGRect.zero
      renderedView.addSubview(childView)
    }

    return renderedView
  }

  public func sizeThatFits(_ size: CGSize) -> CGSize {
    let layout = flexNode.layout(withMaxWidth: size.width)

    apply(layout: layout)

    return layout.frame.size
  }

  private func apply(layout: Layout) {
    for (index, layout) in layout.children.enumerated() {
      let child = children[index]
      child.calculatedFrame = layout.frame
      if let child = child as? BoxView {
        child.apply(layout: layout)
      }
    }
  }
}

typealias FlexNode = SwiftBox.Node

extension View {
  var flexSize: CGSize {
    let width: CGFloat = propertyProvider?.get("width") ?? FlexNode.Undefined
    let height: CGFloat = propertyProvider?.get("height") ?? FlexNode.Undefined

    return CGSize(width: width, height: height)
  }

  public var flex: CGFloat {
    return propertyProvider?.get("flex") ?? 0
  }

  public var margin: Edges {
    return Edges(left: propertyProvider?.get("marginLeft") ?? 0, right: propertyProvider?.get("marginRight") ?? 0, bottom: propertyProvider?.get("marginBottom") ?? 0, top: propertyProvider?.get("marginTop") ?? 0)
  }

  var selfAlignment: SelfAlignment {
    return propertyProvider?.get("selfAlignment") ?? .flexStart
  }
}

protocol FlexNodeProvider {
  var flexNode: FlexNode { get }
}

extension FlexNodeProvider where Self: View {
  var flexNode: FlexNode {
    return FlexNode(size: flexSize, margin: margin, selfAlignment: selfAlignment, flex: flex)
  }
}

extension BoxView: FlexNodeProvider {
  public var flexDirection: Direction {
    return propertyProvider?.get("flexDirection") ?? .column
  }

  public var padding: Edges {
    return Edges(left: propertyProvider?.get("paddingLeft") ?? 0, right: propertyProvider?.get("paddingRight") ?? 0, bottom: propertyProvider?.get("paddingBottom") ?? 0, top: propertyProvider?.get("paddingTop") ?? 0)
  }

  public var justification: Justification {
    return propertyProvider?.get("justification") ?? .flexStart
  }

  public var childAlignment: ChildAlignment {
    return propertyProvider?.get("childAlignment") ?? .stretch
  }

  var flexNode: FlexNode {
    let flexNodes: [FlexNode] = children.map {
      guard let flexNodeProvider = $0 as? FlexNodeProvider else {
        fatalError("Child in a Box node must implement the FlexNodeProvider protocol")
      }

      return flexNodeProvider.flexNode
    }

    return FlexNode(size: flexSize, children: flexNodes, direction: flexDirection, margin: margin, padding: padding, wrap: false, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
  }
}

extension TextView: FlexNodeProvider {
  var flexNode: FlexNode {
    let measure: ((CGFloat) -> CGSize) = { [weak self] width in
      let effectiveWidth = width.isNaN ? CGFloat.greatestFiniteMagnitude : width
      return self?.sizeThatFits(CGSize(width: effectiveWidth, height: CGFloat.greatestFiniteMagnitude)) ?? CGSize.zero
    }
    return FlexNode(size: flexSize, margin: margin, selfAlignment: selfAlignment, flex: flex, measure: measure)
  }
}

extension ImageView: FlexNodeProvider {}
