public protocol ContainerNode: Node {
  var childNodes: [Node] { get set }

  func add(child: Node)
  func contains(child: Node) -> Bool
}

extension ContainerNode {
  public func add(child: Node) {
    if contains(child) {
      return
    }

    childNodes.append(child)
  }

  public func contains(child: Node) -> Bool {
    return childNodes.contains { node in
      return node === child
    }
  }
}