public class NodeRegistry {
  static let sharedInstance: NodeRegistry = NodeRegistry()

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
    registerDefinition("Box") { properties in
      return BoxNode()
    }
    registerDefinition("Text") { properties in
      return ViewNode<TextView>()
    }
  }
}