indirect enum NodeReference {
  case Reference(String, [NodeReference], [String: String])

  func makeInstance(withContextProperties contextProperties: [String: Any]?) -> Node {
    if case let .Reference(identifier, _, properties) = self {
      let propertyTypes = NodeRegistry.shared.propertyTypes(forIdentifier: identifier)
      let resolvedProperties = resolve(properties: properties, withContextProperties: contextProperties)
      let validatedProperties = Validation.validate(propertyTypes: propertyTypes, properties: resolvedProperties)

      let node = NodeRegistry.shared.node(withIdentifier: identifier, properties: validatedProperties)

//      if var containerNode = node as? ContainerNode {
//        children.forEach {
//          containerNode.add(child: $0.makeInstance(withContextProperties: contextProperties))
//        }
//      }

      return node
    }
    fatalError("Unknown reference type")
  }

  private func resolve(properties: [String: String], withContextProperties contextProperties: [String: Any]?) -> [String: Any] {
    var resolvedProperties = [String: Any]()
    for (key, value) in properties {
      resolvedProperties[key] = resolve(value, properties: contextProperties)
    }

    return resolvedProperties
  }

  private func resolve(_ value: Any, properties: [String: Any]?) -> Any? {
    guard let expression = value as? String, expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.characters.index(expression.startIndex, offsetBy: 1)
    let keyPath = expression.substring(from: startIndex)

    return properties?.value(forKey: keyPath)
  }
}

struct NodeDefinition {
  let name: String
  let dependencies: [URL]
  let root: NodeReference
  let propertyTypes: [String: ValidationType]

  func makeNode(withProperties properties: [String: Any]?) -> Node {
    let validatedProperties = Validation.validate(propertyTypes: propertyTypes, properties: properties ?? [:])
    return root.makeInstance(withContextProperties: validatedProperties)
  }
}
