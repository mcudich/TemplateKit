public protocol ContainerNode: LeafNode {
  typealias View = UIView

  var children: [Node] { get set }
  func add(child: Node)
  func contains(child: Node) -> Bool

  init(properties: [String: Any], children: () -> [Node])
}

extension ContainerNode {
  public func add(child: Node) {
    children.append(child)
  }

  public func contains(child: Node) -> Bool {
    return children.contains { $0 === child }
  }

  public func applyProperties(to view: UIView) {}

  public func buildView() -> UIView {
    let parent = renderedView ?? UIView()

    for subview in parent.subviews {
      subview.removeFromSuperview()
    }

    for child in children {
      let childView = child.render()
      parent.addSubview(childView)
    }

    return parent
  }
}
