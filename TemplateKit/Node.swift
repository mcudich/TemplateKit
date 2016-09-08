import UIKit

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol ElementRepresentable {
  // TODO(mcudich): Consider making this generic.
  func make(_ properties: [String: Any], _ children: [Element]?) -> BaseNode

  func equals(_ other: ElementRepresentable) -> Bool
}

public protocol BaseNode: class {
  var properties: [String: Any] { get set }
  var children: [BaseNode]? { get set }
  var currentElement: Element? { get set }
  var currentInstance: BaseNode? { get set }

  func build() -> NativeView

  func insert(child: BaseNode, at index: Int?)
  func remove(child: BaseNode)
  func index(of child: BaseNode) -> Int?
}

public extension BaseNode {
  public var currentInstance: BaseNode? {
    set {}
    get { return self }
  }

  func insert(child: BaseNode, at index: Int? = nil) {
    children?.insert(child, at: index ?? children!.endIndex)
  }

  func remove(child: BaseNode) {
    guard let index = index(of: child) else {
      return
    }
    children?.remove(at: index)
  }

  func index(of child: BaseNode) -> Int? {
    return children?.index(where: { $0 === child })
  }

  func performDiff(newElement: Element) {
    guard let currentInstance = currentInstance else {
      fatalError()
    }

    maybeUpdateProperties(instance: currentInstance, with: newElement)
    currentElement = newElement

    let children = newElement.children ?? []

    var currentChildren = currentInstance.children ?? []
    for element in children {
      if currentChildren.count == 0 {
        append(element)
        continue
      }

      let instance = currentChildren.removeFirst()
      if shouldReplace(instance, with: element) {
        replace(instance, with: element)
      } else {
        maybeUpdateProperties(instance: instance, with: element)
        // TODO(mcudich): Make this more generic.
        if let node = instance as? Node {
          instance.performDiff(newElement: node.render())
        } else {
          instance.performDiff(newElement: element)
        }
      }
    }

    for child in currentChildren {
      remove(child: child)
    }
  }

  func shouldReplace(_ instance: BaseNode, with element: Element) -> Bool {
    if case ElementType.node(let classType) = element.type {
      return classType != type(of: instance)
    }

    return !element.type.equals(instance.currentElement!.type)
  }

  func maybeUpdateProperties(instance: BaseNode, with element: Element) {
    if instance.properties == element.properties {
      return
    }
    instance.properties = element.properties
  }

  func replace(_ instance: BaseNode, with element: Element) {
    let replacement = UIKitRenderer.instantiate(element)
    guard let index = index(of: instance) else {
      fatalError()
    }
    remove(child: instance)
    insert(child: replacement, at: index)
  }

  func append(_ element: Element) {
    insert(child: UIKitRenderer.instantiate(element))
  }
}

public protocol Node: BaseNode {
  static var propertyTypes: [String: ValidationType] { get }

  var state: Any? { get set }
  var key: String? { get }

  init(properties: [String: Any])

  func render() -> Element
  func updateState(stateMutation: () -> Any?)
}

public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
  return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

public func !=(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
  return !NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

public func ==(lhs: Node, rhs: Node) -> Bool {
  return lhs.properties == rhs.properties && lhs.key == rhs.key
}

public extension Node {
  public static var commonPropertyTypes: [String: ValidationType] {
    return [
      "x": Validation.float,
      "y": Validation.float,
      "width": Validation.float,
      "height": Validation.float,
      "marginTop": Validation.float,
      "marginBottom": Validation.float,
      "marginLeft": Validation.float,
      "marginRight": Validation.float,
      "selfAlignment": FlexboxValidation.selfAlignment,
      "flex": Validation.float,
      "onTap": Validation.any
    ]
  }

  public static var propertyTypes: [String: ValidationType] {
    return commonPropertyTypes
  }

  public func updateState(stateMutation: () -> Any?) {
    state = stateMutation()
    update()
  }

  public var key: String? {
    return get("key")
  }

  public var children: [BaseNode]? {
    get {
      return currentInstance?.children
    }
    set {
      currentInstance?.children = newValue
    }
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }

  public func build() -> NativeView {
    guard let currentInstance = currentInstance else {
      fatalError()
    }

    return currentInstance.build()
  }

  func update() {
    DispatchQueue.global(qos: .background).async {
      self.performDiff(newElement: self.render())
      let layout = Layout.perform(UIKitRenderer.materialize(self))

      DispatchQueue.main.async {
        let builtView = self.build() as! UIView
        Layout.apply(layout, to: builtView)
      }
    }
  }
}
