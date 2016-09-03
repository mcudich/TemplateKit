import Foundation
import AEXML

struct Template {
  let root: NodeReference

  func makeNode(withProperties properties: [String: Any]?) -> Node {
    return root.makeInstance(withContextProperties: properties)
  }

  static func parse(xml: Data) throws -> Template {
    let document = try AEXMLDocument(xmlData: xml)

    return Template(root: document.root.nodeReference)
  }
}

extension AEXMLElement {
  var nodeReference: NodeReference {
    return .Reference(name, children.map { $0.nodeReference }, attributes)
  }
}

indirect enum NodeReference {
  case Reference(String, [NodeReference], [String: String])

  func makeInstance(withContextProperties contextProperties: [String: Any]?) -> Node {
    if case let .Reference(identifier, children, properties) = self {
      let resolvedProperties = resolve(properties: properties, withContextProperties: contextProperties)
      let node = NodeRegistry.shared.node(withIdentifier: identifier, properties: resolvedProperties)

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
    let keyPath = expression.substring(from: startIndex)
    
    return properties?.value(forKey: keyPath)
  }
}
