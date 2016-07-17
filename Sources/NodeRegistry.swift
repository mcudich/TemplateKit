public class NodeRegistry {
  static let sharedInstance: NodeRegistry = NodeRegistry()

  private lazy var definitions = [String: Node.Type]()

  init() {
    registerDefaultTypes()
  }

  public func registerDefinition(identifier: String, type: Node.Type) {
    definitions[identifier] = type
  }

  public func typeWithIdentifier(identifier: String) -> Node.Type? {
    return definitions[identifier]
  }

  private func registerDefaultTypes() {
    registerDefinition("Box", type: BoxNode.self)
    registerDefinition("Text", type: TextNode.self)
  }
}