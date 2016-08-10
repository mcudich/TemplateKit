import UIKit
import SwiftBox

typealias FlexNode = SwiftBox.Node

public class BoxNode: ContainerNode {
  public var id: String?
  public var properties: [String: Any]
  public var model: Model?

  public var flexDirection: FlexDirection? {
    set {
      properties["flexDirection"] = x
    }
    get {
      return properties["flexDirection"] as? FlexDirection
    }
  }

  public var flex: CGFloat? {
    set {
      properties["flex"] = x
    }
    get {
      return properties["flex"] as? CGFloat
    }
  }

  public lazy var childNodes = [Node]()
  public lazy var view: UIView = UIView()

  public required init(properties: [String: String] = [:]) {
    self.properties = properties
  }

  public func measure(size: CGSize? = nil) -> CGSize {
    let layout = flexNode.layout(maxWidth: size?.width)

    applyLayout(layout)

    return layout.frame.size
  }

  public func render() -> UIView {
    view.frame = frame
    for child in childNodes {
      let childView = child.render()
      view.addSubview(childView)
    }
    return view
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

extension FlexDirection {
  var value: SwiftBox.Direction {
    switch self {
    case .Column:
      return SwiftBox.Direction.Column
    case .Row:
      return SwiftBox.Direction.Row
    }
  }
}

extension Node {
  var flexSize: CGSize {
    return CGSize(width: width ?? FlexNode.Undefined, height: height ?? FlexNode.Undefined)
  }

  var flexNode: FlexNode {
    return FlexNode()
  }
}

extension BoxNode {
  var flexNode: FlexNode {
    var children = [FlexNode]()
    children = childNodes.map { $0.flexNode }
    return FlexNode(size: flexSize, children: children, direction: flexDirection?.value ?? .Row, margin: Edges(), padding: Edges(), wrap: false, justification: .FlexStart, selfAlignment: .Auto, childAlignment: .Stretch, flex: flex ?? 0)
  }
}

extension ViewNode where ViewNode.V == TextView {
  var flexNode: FlexNode {
    let measure = { [weak self] width in
      return self?.sizeThatFits(CGSize(width: width, height: CGFloat.max)) ?? CGSizeZero
    }
    return FlexNode(measure: measure)
  }
}
