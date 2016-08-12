public class NodeRegistry {
  static let shared = NodeRegistry()

  public typealias NodeInstanceProvider = () -> Node
  private lazy var definitions = [String: NodeInstanceProvider]()

  init() {
    registerDefaultTypes()
  }

  public func registerDefinition(identifier: String, nodeInstanceProvider: NodeInstanceProvider) {
    definitions[identifier] = nodeInstanceProvider
  }

  public func nodeWithIdentifier(identifier: String) -> Node {
    guard let nodeInstanceProvider = definitions[identifier] else {
      // TODO(mcudich): Throw an error instead.
      fatalError()
    }
    return nodeInstanceProvider()
  }

  private func registerDefaultTypes() {
    registerDefinition("Box") {
      return BoxNode()
    }

    registerDefinition("Text") {
      return ViewNode<TextView>()
    }

    registerDefinition("Image") {
      return ViewNode<ImageView>()
    }
  }
}