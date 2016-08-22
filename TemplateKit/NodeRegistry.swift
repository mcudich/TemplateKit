public class NodeRegistry {
  static let shared = NodeRegistry()

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
      // TODO(mcudich): Throw an error instead.
      fatalError()
    }
    return propertyTypes
  }

  private func registerDefaultProviders() {
    register(nodeInstanceProvider: { BoxNode(properties: $0) }, forIdentifier: "Box")
    register(nodeInstanceProvider: { ViewNode<TextView>(properties: $0) }, forIdentifier: "Text")
    register(nodeInstanceProvider: { ViewNode<ImageView>(properties: $0) }, forIdentifier: "Image")

    let defaultPropertyTypes: [String: ValidationType] = [
      "x": Validation.float,
      "y": Validation.float,
      "width": Validation.float,
      "height": Validation.float,
      "marginTop": Validation.float,
      "marginBottom": Validation.float,
      "marginLeft": Validation.float,
      "marginRight": Validation.float,
      "selfAlignment": FlexboxValidation.selfAlignment,
    ]

    let boxTypes = defaultPropertyTypes.merged(with: [
      "flexDirection": FlexboxValidation.flexDirection,
      "paddingTop": Validation.float,
      "paddingBottom": Validation.float,
      "paddingLeft": Validation.float,
      "paddingRight": Validation.float,
      "justification": FlexboxValidation.justification,
      "childAlignment": FlexboxValidation.childAlignment
    ])

    let textTypes = defaultPropertyTypes.merged(with: [
      "text": Validation.string
    ])

    let imageTypes = defaultPropertyTypes.merged(with: [
      "url": Validation.url,
      "contentMode": ImageValidation.contentMode
    ])

    register(propertyTypes: boxTypes, forIdentifier: "Box")
    register(propertyTypes: textTypes, forIdentifier: "Text")
    register(propertyTypes: imageTypes, forIdentifier: "Image")
  }
}
