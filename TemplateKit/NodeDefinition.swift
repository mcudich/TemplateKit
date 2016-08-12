struct NodeDefinition {
  let identifier: String
  let children: [NodeDefinition]
  let properties: [String: String]

  func provideNode() -> Node {
    let node = NodeRegistry.shared.nodeWithIdentifier(identifier)
    var propertyTypes = defaultPropertyTypes
    propertyTypes.merge(node.dynamicType.propertyTypes)
    node.properties = Validation.validate(propertyTypes, properties: properties)

    if let containerNode = node as? ContainerNode {
      children.forEach {
        containerNode.add($0.provideNode())
      }
    }

    return node
  }
}
