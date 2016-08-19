import Foundation
import AEXML

enum ReservedElementName: String {
  case PropertyTypes
}

enum Template {
  static func process(xml: Data) -> NodeDefinition? {
    do {
      let document = try AEXMLDocument(xmlData: xml)
      // TODO(mcudich): Throw if any of this is malformed.
      let rootNodeElement = document.root.children.filter { ReservedElementName(rawValue: $0.name) == nil }.first!
      let propertyTypes = collectPropertyTypes(rootElement: document.root)
      return NodeDefinition(identifier: document.root.attributes["id"]!, root: rootNodeElement.nodeReference, propertyTypes: propertyTypes)
    } catch let error as NSError {
      print("Error loading template : \(error)")
    }
    return nil
  }

  private static func collectPropertyTypes(rootElement: AEXMLElement) -> [String: ValidationType] {
    let propertyTypesElement = rootElement.children.filter { ReservedElementName(rawValue: $0.name) == .PropertyTypes }.first!

    var types = [String: ValidationType]()
    for child in propertyTypesElement.children {
      let key = child.attributes["key"]!
      let type = child.attributes["type"]!
      var validationType: ValidationType? = Validation(rawValue: type) ?? FlexboxValidation(rawValue: type)
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
