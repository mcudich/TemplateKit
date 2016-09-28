import Foundation

public struct Template: Equatable {
  fileprivate let document: XMLElement

  init(xml: Data) throws {
    self.document = try XMLDocumentParser(data: xml).parse()
  }

  func makeElement(with model: Model) throws -> Element {
    guard let componentElement = document.componentElement else {
      throw TemplateKitError.parserError("Malformed document")
    }

    var styleSheet: StyleSheet?
    if let styleElement = document.styleElement, let styleText = styleElement.value {
      styleSheet = StyleSheet(string: styleText)
    }

    var tree = try componentElement.makeElement(with: model, styleSheet: styleSheet)
    tree.applyStyleSheet(styleSheet)
    return tree
  }

  fileprivate static func resolve(properties: [String: String], withModel model: Model?) -> [String: Any] {
    var resolvedProperties = [String: Any]()
    for (key, value) in properties {
      resolvedProperties[key] = resolve(value, model: model)
    }

    return resolvedProperties
  }

  private static func resolve(_ value: Any, model: Model?) -> Any? {
    guard let expression = value as? String, expression.hasPrefix("$") else {
      return value
    }

    let startIndex = expression.characters.index(expression.startIndex, offsetBy: 1)
    let keyPath = expression.substring(from: startIndex)

    return model?.value(forKeyPath: keyPath)
  }
}

public func ==(lhs: Template, rhs: Template) -> Bool {
  return false
}

extension XMLElement {
  var styleElement: XMLElement? {
    return children.first { candidate in
      return candidate.name == "style"
    }
  }

  var componentElement: XMLElement? {
    return children.first { candidate in
      return candidate.name != "style"
    }
  }

  func makeElement(with model: Model, styleSheet: StyleSheet?) throws -> Element {
    let resolvedProperties = Template.resolve(properties: attributes, withModel: model)
    return NodeRegistry.shared.buildElement(with: name, properties: resolvedProperties, children: try children.map { try $0.makeElement(with: model, styleSheet: styleSheet) })
  }
}
