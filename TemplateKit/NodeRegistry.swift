public class NodeRegistry {
  public static let shared = NodeRegistry()

  private lazy var propertyTypes = [String: [String: ValidationType]]()
  private lazy var componentTypes = [String: AnyClass]()

  init() {
    registerDefaultProviders()
  }

  public func register(_ propertyTypes: [String: ValidationType], for name: String) {
    self.propertyTypes[name] = propertyTypes
  }

  public func register(_ classType: AnyClass, for name: String) {
    componentTypes[name] = classType
    if let propertyTypeProvider = classType as? PropertyTypeProvider.Type {
      register(propertyTypeProvider.propertyTypes, for: name)
    }
  }

  func propertyTypes(for name: String) -> [String: ValidationType] {
    guard let propertyTypes = propertyTypes[name] else {
      return [:]
    }
    return propertyTypes
  }

  func componentType(for name: String) throws -> AnyClass {
    guard let nodeType = componentTypes[name] else {
      throw TemplateKitError.missingNodeType("Node type not found for \(name)")
    }
    return nodeType
  }

  private func registerDefaultProviders() {
    register(Box.propertyTypes, for: "box")
    register(Text.propertyTypes, for: "text")
    register(Image.propertyTypes, for: "image")
  }
}
