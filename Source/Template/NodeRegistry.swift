public class NodeRegistry {
  public typealias ElementBuilder = ([String: Any], [Element]?) -> Element
  public static let shared = NodeRegistry()

  private lazy var elementBuilders = [String: ElementBuilder]()

  init() {
    registerDefaultProviders()
  }

  public func registerElementBuilder(_ name: String, builder: @escaping ElementBuilder) {
    self.elementBuilders[name] = builder
  }

  func buildElement(with name: String, properties: [String: Any], children: [Element]?) -> Element {
    return elementBuilders[name]!(properties, children)
  }

  private func registerDefaultProviders() {
    registerElementBuilder("box") { properties, children in
      return ElementData(ElementType.box, BaseProperties(properties), children)
    }
    registerElementBuilder("text") { properties, children in
      return ElementData(ElementType.text, TextProperties(properties))
    }
    registerElementBuilder("textfield") { properties, children in
      return ElementData(ElementType.textField, TextFieldProperties(properties))
    }
    registerElementBuilder("image") { properties, children in
      return ElementData(ElementType.image, ImageProperties(properties))
    }
    registerElementBuilder("button") { properties, children in
      return ElementData(ElementType.button, ButtonProperties(properties))
    }
  }
}
