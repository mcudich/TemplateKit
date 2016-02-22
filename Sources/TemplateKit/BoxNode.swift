import UIKit
import SwiftBox

typealias FlexNode = SwiftBox.Node

public class BoxNode: Node {
  private lazy var children = OrderedSet<Node>()

  public var childNodes: [Node] {
    return children.array
  }

  public func add(child: Node) {
    children.add(child)
  }

  public func contains(child: Node) -> Bool {
    return children.contains(child)
  }

  public override func measure(size: CGSize) -> CGSize {
    let layout = flexNode.layout()

    let children = childNodes
    for (index, layout) in layout.children.enumerate() {
      children[index].frame = layout.frame
    }

    return layout.frame.size
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

    return FlexNode(size: flexSize, children: children, margin: Edges(), padding: Edges(), wrap: false, justification: .FlexStart, selfAlignment: .Auto, childAlignment: .Stretch, flex: flex ?? 0, measure: nil)
  }
}
