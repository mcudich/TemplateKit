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
    return try Template.parse(xml: data)
  }
}

public class TemplateService {
  let resourceService = ResourceService<TemplateParser>()

  public init() {}
}

extension TemplateService: NodeProvider {
  public func node(withLocation location: URL, properties: [String : Any]?, completion: NodeResultHandler) {
    loadTemplate(withLocation: location, completion: processDefinition(withLocation: location) { result in
      switch result {
      case .success(let definition):
        completion(.success(definition.makeNode(withProperties: properties)))
      case .error(let error):
        completion(.error(error))
      }
    })
  }

  private func loadTemplate(withLocation location: URL, completion: NodeDefinitionResultHandler) {
    resourceService.load(location, completion: completion)
  }

  private func processDefinition(withLocation location: URL, completion: NodeDefinitionResultHandler) -> NodeDefinitionResultHandler {
    return { [weak self] result in
      switch result {
      case .success(let definition):
        self?.registerDefinition(definition)
        self?.loadDependencies(definition.dependencies, withRelativeURL: location) {
          completion(result)
        }
      case .error(_):
        completion(result)
      }
    }
  }

  private func registerDefinition(_ definition: NodeDefinition) {
    NodeRegistry.shared.register(nodeInstanceProvider: definition.makeNode, forIdentifier: definition.name)
    NodeRegistry.shared.register(propertyTypes: definition.propertyTypes, forIdentifier: definition.name)
  }

  private func loadDependencies(_ dependencies: [URL], withRelativeURL relativeURL: URL, completion: @escaping () -> Void) {
    if dependencies.isEmpty {
      return completion()
    }

    var pendingDependencies = Set(dependencies)
    for dependency in dependencies {
      let resolvedURL = URL(string: dependency.absoluteString, relativeTo: relativeURL)!
      loadTemplate(withLocation: resolvedURL, completion: processDefinition(withLocation: resolvedURL) { dependencyResult in
        pendingDependencies.remove(dependency)
        if pendingDependencies.count == 0 {
          completion()
        }
      })
    }
  }
}
