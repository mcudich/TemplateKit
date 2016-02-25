struct NodeDefinition {
  let identifier: String
  let children: [NodeDefinition]
  let properties: [String: String]

  func provideNode() -> Node {
    let type = NodeRegistry.sharedInstance.typeWithIdentifier(identifier)!
    let node = type.init(properties: properties)

    if let containerNode = node as? BoxNode {
      children.forEach {
        containerNode.add($0.provideNode())
      }
    }

    return node
  }
}
