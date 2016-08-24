import Foundation
import AEXML

enum ReservedElementName: String {
  case PropertyTypes
  case Imports
}

enum Template {
  static func parse(xml: Data) -> NodeDefinition? {
    do {
      let document = try AEXMLDocument(xmlData: xml)
      // TODO(mcudich): Throw if any of this is malformed.
      let dependencies = collectDependencies(rootElement: document.root)
      let rootNodeElement = document.root.children.first { element in
        return ReservedElementName(rawValue: element.name) == nil
      }!
      let propertyTypes = collectPropertyTypes(rootElement: document.root)
      return NodeDefinition(identifier: document.root.attributes["id"]!, dependencies: dependencies, root: rootNodeElement.nodeReference, propertyTypes: propertyTypes)
    } catch let error as NSError {
      print("Error loading template : \(error)")
    }
    return nil
  }

  private static func collectDependencies(rootElement: AEXMLElement) -> [URL] {
    let importsElement = rootElement.children.first { element in
      return element.name == ReservedElementName.Imports.rawValue
    }
    return importsElement?.children.map { tag in
      return URL(string: tag.attributes["url"]!)!
    } ?? []
  }

  private static func collectPropertyTypes(rootElement: AEXMLElement) -> [String: ValidationType] {
    let propertyTypesElement = rootElement.children.first { element in
      return element.name == ReservedElementName.PropertyTypes.rawValue
    }!

    var types = [String: ValidationType]()
    for child in propertyTypesElement.children {
      let key = child.attributes["key"]!
      let type = child.attributes["type"]!
      // TODO(mcudich): XML should express validation domain.
      let validationType: ValidationType? = Validation(rawValue: type) ?? FlexboxValidation(rawValue: type) ?? ImageValidation(rawValue: type) ?? TextValidation(rawValue: type)
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
