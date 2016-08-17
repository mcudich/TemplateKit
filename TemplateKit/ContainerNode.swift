public protocol ContainerNode: Node {
  var children: [Node] { get }
  func add(child: Node)
  func contains(child: Node) -> Bool
}

extension ContainerNode {
  public func contains(child: Node) -> Bool {
    return children.contains { $0 === child }
  }
}
