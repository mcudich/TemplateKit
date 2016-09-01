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
    return children.contains { $0 == child }
  }

  public func applyProperties(to view: UIView) {}

  public func buildView() -> UIView {
    let parent = renderedView ?? UIView()

    for subview in parent.subviews {
      subview.removeFromSuperview()
    }

    var views: [UIView?] = [UIView?](repeating: nil, count: children.count)
    for (index, child) in children.enumerated() {
      child.render { view in
        views[index] = view
        if views.count == self.children.count {
          views.forEach { subview in
            guard let subview = subview else { return }
            parent.addSubview(subview)
          }
        }
      }
    }
    return parent
  }
}
