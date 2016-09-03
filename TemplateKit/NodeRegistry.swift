public class NodeRegistry {
  public static let shared = NodeRegistry()
  public static let defaultPropertyTypes: [String: ValidationType] = [
    "x": Validation.float,
    "y": Validation.float,
    "width": Validation.float,
    "height": Validation.float,
    "marginTop": Validation.float,
    "marginBottom": Validation.float,
    "marginLeft": Validation.float,
    "marginRight": Validation.float,
    "flex": Validation.float,
    "onTap": Validation.any
  ]

  public typealias NodeInstanceProvider = ([String: Any]) -> Node
  private lazy var providers = [String: NodeInstanceProvider]()
  private lazy var propertyTypes = [String: [String: ValidationType]]()

  init() {
    registerDefaultProviders()
  }

  public func register(nodeInstanceProvider: NodeInstanceProvider, forIdentifier identifier: String) {
    providers[identifier] = nodeInstanceProvider
  }

  public func register(propertyTypes: [String: ValidationType], forIdentifier identifier: String) {
    self.propertyTypes[identifier] = propertyTypes
  }

  func node(withIdentifier identifier: String, properties: [String: Any]) -> Node {
    guard let nodeInstanceProvider = providers[identifier] else {
      // TODO(mcudich): Throw an error instead.
      fatalError()
    }
    return nodeInstanceProvider(properties)
  }

  func propertyTypes(forIdentifier identifier: String) -> [String: ValidationType] {
    guard let propertyTypes = propertyTypes[identifier] else {
      return [:]
    }
    return propertyTypes
  }

  private func registerDefaultProviders() {
    let boxTypes = NodeRegistry.defaultPropertyTypes.merged(with: [
      "paddingTop": Validation.float,
      "paddingBottom": Validation.float,
      "paddingLeft": Validation.float,
      "paddingRight": Validation.float
    ])

    let textTypes = NodeRegistry.defaultPropertyTypes.merged(with: [
      "text": Validation.string,
      "fontName": Validation.string,
      "fontSize": Validation.float,
      "textColor": Validation.color
    ])

    let imageTypes = NodeRegistry.defaultPropertyTypes.merged(with: [
      "url": Validation.url,
      "name": Validation.string
    ])

    register(propertyTypes: boxTypes, forIdentifier: "Box")
    register(propertyTypes: textTypes, forIdentifier: "Text")
    register(propertyTypes: imageTypes, forIdentifier: "Image")
  }
}
