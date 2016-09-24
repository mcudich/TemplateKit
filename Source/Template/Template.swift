import Foundation
import AEXML

public struct Template: Equatable {
  fileprivate let document: AEXMLDocument

  init(xml: Data) throws {
    self.document = try AEXMLDocument(xml: xml)
  }

  func makeElement(with properties: Properties) throws -> Element {
    return try document.root.makeElement(with: properties)
  }
}

public func ==(lhs: Template, rhs: Template) -> Bool {
  return lhs.document.xml == rhs.document.xml
}

extension AEXMLElement {
  func makeElement(with properties: Properties) throws -> Element {
    let resolvedProperties = resolve(properties: attributes, withContextProperties: properties)
    return NodeRegistry.shared.buildElement(with: name, properties: resolvedProperties, children: try children.map { try $0.makeElement(with: properties) })
  }

  private func resolve(properties: [String: String], withContextProperties contextProperties: Properties?) -> [String: Any] {
    var resolvedProperties = [String: Any]()
    for (key, value) in properties {
      resolvedProperties[key] = resolve(value, properties: contextProperties)
    }

    return resolvedProperties
  }

  private func resolve(_ value: Any, properties: Properties?) -> Any? {
    guard let expression = value as? String, expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.characters.index(expression.startIndex, offsetBy: 1)
    let keyPath = expression.substring(from: startIndex)

    return properties?.value(forKeyPath: keyPath)
  }
}
