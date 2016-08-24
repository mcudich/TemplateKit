import UIKit

public typealias NodeResultHandler = (Result<Node>) -> Void
typealias NodeDefinitionResultHandler = (Result<NodeDefinition>) -> Void

public protocol NodeProvider {
  func node(withLocation location: URL, properties: [String: Any]?, completion: NodeResultHandler)
}

class TemplateParser: Parser {
  typealias ParsedType = NodeDefinition

  required init() {}

  func parse(data: Data) throws -> NodeDefinition {
    guard let definition = Template.parse(xml: data) else {
      throw TemplateKitError.parserError("Invalid template data")
    }
    return definition
  }
}

public class TemplateClient {
  let templateService = NetworkService<TemplateParser, NodeDefinition>()
}

extension TemplateClient: NodeProvider {
  public func node(withLocation location: URL, properties: [String : Any]?, completion: NodeResultHandler) {
    templateService.load(location, completion: processDefinition { result in
      switch result {
      case .success(let definition):
        completion(.success(definition.makeNode(withProperties: properties)))
      case .error(let error):
        completion(.error(error))
      }
    })
  }

  private func processDefinition(completion: NodeDefinitionResultHandler) -> NodeDefinitionResultHandler {
    return { [weak self] result in
      guard let weakSelf = self else { return }

      switch result {
      case .success(let definition):
        NodeRegistry.shared.register(nodeInstanceProvider: definition.makeNode, forIdentifier: definition.identifier)
        NodeRegistry.shared.register(propertyTypes: definition.propertyTypes, forIdentifier: definition.identifier)

        if definition.dependencies.isEmpty {
          return completion(result)
        }

        var pendingDependencies = Set(definition.dependencies)
        for dependency in definition.dependencies {
          weakSelf.templateService.load(dependency, completion: weakSelf.processDefinition { result in
            pendingDependencies.remove(dependency)
            if pendingDependencies.count == 0 {
              completion(result)
            }
          })
        }
      case .error(_):
        completion(result)
      }
    }
  }
}
