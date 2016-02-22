struct NodeDefinition {
  let identifier: String
  let children: [NodeDefinition]

  func provideNode() -> Node {
    let type = NodeRegistry.sharedInstance.typeWithIdentifier(identifier)!
    return type.init()
  }
}