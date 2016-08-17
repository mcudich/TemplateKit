struct NodeDefinition {
  let identifier: String
  let children: [NodeDefinition]
  let properties: [String: String]

  func makeNode(withModel model: Model?) -> Node {
    let propertyTypes = NodeRegistry.shared.propertyTypes(forIdentifier: identifier)
    let resolvedProperties = resolveProperties(withModel: model)
    let validatedProperties = Validation.validate(propertyTypes: propertyTypes, properties: resolvedProperties)

    let node = NodeRegistry.shared.node(withIdentifier: identifier, properties: validatedProperties)

    if let containerNode = node as? ContainerNode {
      children.forEach {
        containerNode.add(child: $0.makeNode(withModel: model))
      }
    }

    return node
  }

  private func resolveProperties(withModel model: Model?) -> [String: Any] {
    var resolvedProperties = [String: Any]()
    for (key, value) in properties {
      resolvedProperties[key] = resolve(value, model: model)
    }

    return resolvedProperties
  }

  private func resolve(_ value: Any, model: Model?) -> Any {
    guard let expression = value as? String, expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.characters.index(expression.startIndex, offsetBy: 1);
    let key = expression.substring(from: startIndex);
    return model?.value(forKey: key)
  }
}
