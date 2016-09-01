public protocol ContainerNode: Node {
  var children: [Node] { get set }
  mutating func add(child: Node)
  func contains(child: Node) -> Bool

  init(properties: [String: Any], children: () -> [Node])
}

extension ContainerNode {
  public mutating func add(child: Node) {
    children.append(child)
  }

  public func contains(child: Node) -> Bool {
    return children.contains { $0 == child }
  }

  public func render(completion: @escaping (UIView) -> Void) {
    let parent = UIView()
    parent.frame = calculatedFrame ?? CGRect.zero

    var views: [UIView?] = [UIView?](repeating: nil, count: children.count)
    for (index, child) in children.enumerated() {
      child.render { view in
        if let calculatedFrame = child.calculatedFrame {
          view.frame = calculatedFrame
        }
        views[index] = view
        if views.count == self.children.count {
          views.forEach { subview in
            guard let subview = subview else { return }
            parent.addSubview(subview)
          }
          completion(parent)
        }
      }
    }
  }
}
