public protocol ContainerNode {
  var childNodes: [Node] { get }

  func add(child: Node)

  func contains(child: Node) -> Bool
}