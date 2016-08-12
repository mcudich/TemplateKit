struct NodeDefinition {
  let identifier: String
  let children: [NodeDefinition]
  let properties: [String: String]

  func provideNode() -> Node {
    let node = NodeRegistry.shared.node(withIdentifier: identifier)
    var propertyTypes = defaultPropertyTypes
    propertyTypes.merge(with: node.dynamicType.propertyTypes)
    node.properties = Validation.validate(propertyTypes: propertyTypes, properties: properties)

    if let containerNode = node as? ContainerNode {
      children.forEach {
        containerNode.add(child: $0.provideNode())
      }
    }

    return node
  }
}
