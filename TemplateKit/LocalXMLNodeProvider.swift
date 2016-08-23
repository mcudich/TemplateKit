import UIKit
import AEXML

class LocalXMLNodeProvider {
  fileprivate lazy var definitions = [String: NodeDefinition]()

  private let bundle: Bundle
  private let directory: String?

  init(bundle: Bundle, directory: String?) {
    self.bundle = bundle
    self.directory = directory
  }

  fileprivate func loadTemplates() throws {
    try bundle.urls(forResourcesWithExtension: "xml", subdirectory: directory)?.forEach(loadTemplate)
  }

  private func loadTemplate(withURL url: URL) throws {
    let xml = try Data(contentsOf: url)
    if let definition = Template.process(xml: xml) {
      definitions[definition.identifier] = definition
      NodeRegistry.shared.register(nodeInstanceProvider: definition.makeNode, forIdentifier: definition.identifier)
      NodeRegistry.shared.register(propertyTypes: definition.propertyTypes, forIdentifier: definition.identifier)
    }
  }
}

extension LocalXMLNodeProvider: TemplateProvider {
  func fetchTemplates(completion: @escaping (Result<Void>) -> Void) {
    DispatchQueue.global(qos: .background).async { [weak self] in
      do {
        try self?.loadTemplates()
      } catch {
        completion(.error(error))
        return
      }
      completion(.success())
    }
  }

  func node(withName name: String, properties: [String: Any]?) -> Node? {
    return definitions[name]?.makeNode(withProperties: properties)
  }
}
