public protocol ContainerNode: Node {
  var children: [Node] { get }
  func add(child: Node)
  func contains(child: Node) -> Bool
}
