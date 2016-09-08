public class NodeRegistry {
  public static let shared = NodeRegistry()

  public typealias NodeInstanceProvider = ([String: Any]) -> Node
  private lazy var providers = [String: NodeInstanceProvider]()
  private lazy var propertyTypes = [String: [String: ValidationType]]()

  init() {
    registerDefaultProviders()
  }

  public func register(_ identifier: String, provider: @escaping NodeInstanceProvider) {
    providers[identifier] = provider
  }

  public func register(_ identifier: String, propertyTypes: [String: ValidationType]) {
    self.propertyTypes[identifier] = propertyTypes
  }

  func node(withIdentifier identifier: String, properties: [String: Any]) throws -> Node {
    guard let nodeInstanceProvider = providers[identifier] else {
      throw TemplateKitError.missingProvider("Provider not found for \(identifier)")
    }
    return nodeInstanceProvider(properties)
  }

  func propertyTypes(forIdentifier identifier: String) throws -> [String: ValidationType] {
    guard let propertyTypes = propertyTypes[identifier] else {
      throw TemplateKitError.missingPropertyTypes("Property types not found for \(identifier)")
    }
    return propertyTypes
  }

  private func registerDefaultProviders() {
//    register("Box") { Box(properties: $0) }
//    register("Text") { Text(properties: $0) }
//    register("Image") { Image(properties: $0) }
//    register("View") { View(properties: $0) }
//
//    register("Box", propertyTypes: Box.propertyTypes)
//    register("Text", propertyTypes: Text.propertyTypes)
//    register("Image", propertyTypes: Image.propertyTypes)
  }
}
