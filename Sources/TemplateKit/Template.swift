import Foundation
import AEXML

class Template {
  static func process(xml: NSData) -> NodeDefinition? {
    do {
      let document = try AEXMLDocument(xmlData: xml)
      return document.root.definition
    } catch let error as NSError {
      print("Error loading template : \(error)")
    }
    return nil
  }
}

extension AEXMLElement {
  var definition: NodeDefinition {
    let identifier = name
    let childNodes = children.map { $0.definition }

    return NodeDefinition(identifier: identifier, children: childNodes, properties: attributes)
  }
}
