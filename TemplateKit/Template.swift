import Foundation
import AEXML

struct Template {
  let root: NodeReference

  init(xml: Data) throws {
    let document = try AEXMLDocument(xmlData: xml)
    root = document.root.nodeReference
  }

  func makeNode(withProperties properties: [String: Any]?) throws -> Node {
    return try root.makeInstance(withContextProperties: properties)
  }
}

extension AEXMLElement {
  var nodeReference: NodeReference {
    return .Reference(name, children.map { $0.nodeReference }, attributes)
  }
}

indirect enum NodeReference {
  case Reference(String, [NodeReference], [String: String])

  func makeInstance(withContextProperties contextProperties: [String: Any]?) throws -> Node {
    if case let .Reference(identifier, children, properties) = self {
      let resolvedProperties = resolve(properties: properties, withContextProperties: contextProperties)
      let propertyTypes = try NodeRegistry.shared.propertyTypes(forIdentifier: identifier)
      let validatedProperties = Validation.validate(propertyTypes: propertyTypes, properties: resolvedProperties)
      let node = try NodeRegistry.shared.node(withIdentifier: identifier, properties: validatedProperties)

//      if let containerNode = node as? ContainerNode {
//        try children.forEach {
//          try containerNode.add(child: $0.makeInstance(withContextProperties: contextProperties))
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
