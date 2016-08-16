let defaultPropertyTypes: [String: ValidationType] = [
  "x": Validation.float,
  "y": Validation.float,
  "width": Validation.float,
  "height": Validation.float,
]

struct NodeDefinition {
  let identifier: String
  let children: [NodeDefinition]
  let properties: [String: String]

  func makeNode(withModel model: Model?) -> Node {
    let node = NodeRegistry.shared.node(withIdentifier: identifier)
    var propertyTypes = defaultPropertyTypes
    propertyTypes.merge(with: node.dynamicType.propertyTypes)

    let resolvedProperties = resolveProperties(withModel: model)
    node.properties = Validation.validate(propertyTypes: propertyTypes, properties: resolvedProperties)

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
