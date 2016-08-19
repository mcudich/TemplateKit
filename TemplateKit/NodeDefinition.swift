indirect enum NodeReference {
  case Reference(String, [NodeReference], [String: String])

  func makeInstance(withContextProperties contextProperties: [String: Any]?) -> Node {
    if case let .Reference(identifier, children, properties) = self {
      let propertyTypes = NodeRegistry.shared.propertyTypes(forIdentifier: identifier)
      let resolvedProperties = resolve(properties: properties, withContextProperties: contextProperties)
      let validatedProperties = Validation.validate(propertyTypes: propertyTypes, properties: resolvedProperties)

      let node = NodeRegistry.shared.node(withIdentifier: identifier, properties: validatedProperties)

      if let containerNode = node as? ContainerNode {
        children.forEach {
          containerNode.add(child: $0.makeInstance(withContextProperties: contextProperties))
        }
      }

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
    let separator = "."
    let keyPath = expression.substring(from: startIndex).components(separatedBy: separator)

    guard let rootPath = keyPath.first, let propertyValue = properties?[rootPath] else {
      return nil
    }

    if keyPath.count > 1, let resolvedModel = propertyValue as? Model {
      return resolvedModel.value(forKey: keyPath.dropFirst().joined(separator: separator))
    } else {
      return propertyValue
    }
  }
}

struct NodeDefinition {
  let identifier: String
  let root: NodeReference
  let propertyTypes: [String: ValidationType]

  func makeNode(withProperties properties: [String: Any]?) -> Node {
    let validatedProperties = Validation.validate(propertyTypes: propertyTypes, properties: properties ?? [:])
    return root.makeInstance(withContextProperties: properties)
  }
}
