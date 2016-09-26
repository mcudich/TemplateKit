import Foundation

public struct Template: Equatable {
  fileprivate let document: XMLElement

  init(xml: Data) throws {
    self.document = try XMLDocumentParser(data: xml).parse()
  }

  func makeElement(with model: Model) throws -> Element {
    return try document.makeElement(with: model)
  }
}

public func ==(lhs: Template, rhs: Template) -> Bool {
  return false
}

extension XMLElement {
  func makeElement(with model: Model) throws -> Element {
    let resolvedProperties = resolve(properties: attributes, withModel: model)
    return NodeRegistry.shared.buildElement(with: name, properties: resolvedProperties, children: try children.map { try $0.makeElement(with: model) })
  }

  private func resolve(properties: [String: String], withModel model: Model?) -> [String: Any] {
    var resolvedProperties = [String: Any]()
    for (key, value) in properties {
      resolvedProperties[key] = resolve(value, model: model)
    }

    return resolvedProperties
  }

  private func resolve(_ value: Any, model: Model?) -> Any? {
    guard let expression = value as? String, expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.characters.index(expression.startIndex, offsetBy: 1)
    let keyPath = expression.substring(from: startIndex)

    return model?.value(forKeyPath: keyPath)
  }
}
