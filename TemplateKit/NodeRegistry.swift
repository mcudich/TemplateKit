public class NodeRegistry {
  public static let shared = NodeRegistry()

  public typealias NodeInstanceProvider = ([String: Any]) -> Node
  private lazy var providers = [String: NodeInstanceProvider]()

  init() {
    registerDefaultProviders()
  }

  public func register(_ identifier: String, provider: NodeInstanceProvider) {
    providers[identifier] = provider
  }

  func node(withIdentifier identifier: String, properties: [String: Any]) -> Node {
    guard let nodeInstanceProvider = providers[identifier] else {
      // TODO(mcudich): Throw an error instead.
      fatalError()
    }
    return nodeInstanceProvider(properties)
  }

  private func registerDefaultProviders() {
    register("Box") { Box(properties: $0) }
    register("Text") { Text(properties: $0) }
    register("Image") { Image(properties: $0) }
    register("View") { View(properties: $0) }
  }
}
