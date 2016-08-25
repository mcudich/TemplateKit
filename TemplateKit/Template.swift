import Foundation
import AEXML

enum ReservedElementName: String {
  case PropertyType
  case Import
}

enum Template {
  static func parse(xml: Data) throws -> NodeDefinition {
    let document = try AEXMLDocument(xmlData: xml)
    let name = try parseName(rootElement: document.root)
    let dependencies = try parseDependencies(rootElement: document.root)
    let rootNodeElement = try parseRootNode(rootElement: document.root)
    let propertyTypes = try parsePropertyTypes(rootElement: document.root)

    return NodeDefinition(name: name, dependencies: dependencies, root: rootNodeElement.nodeReference, propertyTypes: propertyTypes)
  }

  private static func parseName(rootElement: AEXMLElement) throws -> String {
    guard let name = rootElement.attributes["name"] else {
      throw TemplateKitError.parserError("Missing name value")
    }
    return name
  }

  private static func parseDependencies(rootElement: AEXMLElement) throws -> [URL] {
    let importElements = rootElement.children.filter { element in
      return element.name == ReservedElementName.Import.rawValue
    }
    return try importElements.map { tag in
      guard let urlValue = tag.attributes["url"] else {
        throw TemplateKitError.parserError("Import element missing `url` value")
      }
      guard let url = URL(string: urlValue) else {
        throw TemplateKitError.parserError("Import element URL is invalid")
      }
      return url
    }
  }

  private static func parseRootNode(rootElement: AEXMLElement) throws -> AEXMLElement {
    let nodeTag = rootElement.children.first { element in
      return ReservedElementName(rawValue: element.name) == nil
    }
    guard let foundTag = nodeTag else {
      throw TemplateKitError.parserError("Root node element not found")
    }
    return foundTag
  }

  private static func parsePropertyTypes(rootElement: AEXMLElement) throws -> [String: ValidationType] {
    let propertyTypeElements = rootElement.children.filter { element in
      return element.name == ReservedElementName.PropertyType.rawValue
    }

    var types = [String: ValidationType]()
    for child in propertyTypeElements {
      guard let key = child.attributes["key"] else {
        throw TemplateKitError.parserError("Missing `key` value for property type")
      }
      guard let type = child.attributes["type"] else {
        throw TemplateKitError.parserError("Missing `type` value for property type")
      }
      // TODO(mcudich): XML should express validation domain.
      guard let validationType: ValidationType = Validation(rawValue: type) ?? FlexboxValidation(rawValue: type) ?? ImageValidation(rawValue: type) ?? TextValidation(rawValue: type) else {
        throw TemplateKitError.parserError("Unknown validation type")
      }

      types[key] = validationType
    }
    return types
  }
}

extension AEXMLElement {
  var nodeReference: NodeReference {
    return .Reference(name, children.map { $0.nodeReference }, attributes)
  }
}
