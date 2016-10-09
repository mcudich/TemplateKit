public class NodeRegistry {
  public typealias ElementBuilder = ([String: Any], [Element]?) -> Element
  public static let shared = NodeRegistry()

  private lazy var elementBuilders = [String: ElementBuilder]()

  init() {
    registerDefaultProviders()
  }

  public func registerComponent<T: Properties>(_ type: ComponentCreation.Type, _ propertiesType: T.Type) {
    registerElementBuilder("\(type)") { properties, children in
      return component(type, propertiesType.init(properties))
    }
  }

  public func registerElementBuilder(_ name: String, builder: @escaping ElementBuilder) {
    self.elementBuilders[name] = builder
  }

  func buildElement(with name: String, properties: [String: Any], children: [Element]?) -> Element {
    return elementBuilders[name]!(properties, children)
  }

  private func registerDefaultProviders() {
    registerElementBuilder("box") { properties, children in
      return box(DefaultProperties(properties), children)
    }
    registerElementBuilder("text") { properties, children in
      return text(TextProperties(properties))
    }
    registerElementBuilder("textfield") { properties, children in
      return textfield(TextFieldProperties(properties))
    }
    registerElementBuilder("image") { properties, children in
      return image(ImageProperties(properties))
    }
    registerElementBuilder("button") { properties, children in
      return button(ButtonProperties(properties))
    }
  }
}
