import UIKit
import SwiftBox

typealias FlexNode = SwiftBox.Node

public class BoxNode: Node {
  private lazy var children = OrderedSet<Node>()

  public override func measure(size: CGSize? = nil) -> CGSize {
    let layout = flexNode.layout(size?.width)

    applyLayout(layout)

    return layout.frame.size
  }

  public override func render() -> UIView {
    let renderedView = super.render()
    for child in childNodes {
      let childView = child.render()
      renderedView.addSubview(childView)
    }
    return renderedView
  }

  private func applyLayout(layout: Layout) {
    let children = childNodes
    for (index, layout) in layout.children.enumerate() {
      let child = children[index]
      child.frame = layout.frame
      if let child = child as? BoxNode {
        child.applyLayout(layout)
      }
    }
  }
}

extension BoxNode: ContainerNode {
  public var childNodes: [Node] {
    return children.array
  }

  public func add(child: Node) {
    children.add(child)
  }

  public func contains(child: Node) -> Bool {
    return children.contains(child)
  }
}

extension FlexDirection {
  var value: SwiftBox.FlexDirection {
    switch self {
    case .Column:
      return SwiftBox.FlexDirection.Column
    case .Row:
      return SwiftBox.FlexDirection.Row
    }
  }
}

extension Node {
  var flexSize: CGSize {
    return CGSize(width: width ?? FlexNode.Undefined, height: height ?? FlexNode.Undefined)
  }

  var flexNode: FlexNode {
    var children = [FlexNode]()
    if let boxNode = self as? BoxNode {
      children = boxNode.childNodes.map { $0.flexNode }
    }

    var measureText: (CGFloat -> CGSize)?
    if let textNode = self as? TextNode {
      measureText = { width in
        return textNode.measure(CGSize(width: width, height: CGFloat.max))
      }
    }

    return FlexNode(size: flexSize, children: children, flexDirection: flexDirection?.value ?? .Row, margin: Edges(), padding: Edges(), wrap: false, justification: .FlexStart, selfAlignment: .Auto, childAlignment: .Stretch, flex: flex ?? 0, measure: measureText)
  }
}
