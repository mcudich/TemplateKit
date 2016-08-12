public class NodeRegistry {
  static let shared = NodeRegistry()

  public typealias NodeInstanceProvider = () -> Node
  private lazy var definitions = [String: NodeInstanceProvider]()

  init() {
    registerDefaultTypes()
  }

  public func registerDefinition(withIdentifier identifier: String, nodeInstanceProvider: NodeInstanceProvider) {
    definitions[identifier] = nodeInstanceProvider
  }

  public func node(withIdentifier identifier: String) -> Node {
    guard let nodeInstanceProvider = definitions[identifier] else {
      // TODO(mcudich): Throw an error instead.
      fatalError()
    }
    return nodeInstanceProvider()
  }

  private func registerDefaultTypes() {
    registerDefinition(withIdentifier: "Box") {
      return BoxNode()
    }

    registerDefinition(withIdentifier: "Text") {
      return ViewNode<TextView>()
    }

    registerDefinition(withIdentifier: "Image") {
      return ViewNode<ImageView>()
    }
  }
}
