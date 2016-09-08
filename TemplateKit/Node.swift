import UIKit
import SwiftBox

public protocol ElementRepresentable {
  func make(_ properties: [String: Any], _ children: [Element]?, _ owner: Node?) -> BaseNode
  func equals(_ other: ElementRepresentable) -> Bool
}

public protocol PropertyHolder {
  var properties: [String: Any] { get set }

  func get<T>(_ key: String) -> T?
}

public extension PropertyHolder {
  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }
}

public protocol Keyable {
  var key: String? { get }
}

public extension Keyable where Self: PropertyHolder {
  public var key: String? {
    return get("key")
  }
}

public protocol BaseNode: class, PropertyHolder, Keyable {
  weak var owner: Node? { get set }
  var children: [BaseNode]? { get set }
  var currentElement: Element? { get set }
  var currentInstance: BaseNode? { get set }
  var builtView: View? { get }

  func build() -> View
  func computeLayout() -> SwiftBox.Layout

  func insert(child: BaseNode, at index: Int?)
  func remove(child: BaseNode)
  func index(of child: BaseNode) -> Int?
}

public extension BaseNode {
  public var currentInstance: BaseNode? {
    set {}
    get { return self }
  }

  var root: BaseNode? {
    var current: Node? = owner ?? (self as? Node)
    while let currentOwner = current?.owner {
      current = currentOwner
    }
    return current
  }

  func insert(child: BaseNode, at index: Int? = nil) {
    children?.insert(child, at: index ?? children!.endIndex)
  }

  func remove(child: BaseNode) {
    guard let index = index(of: child) else {
      return
    }
    print(">>> Removing \(child)")
    children?.remove(at: index)
  }

  func move(child: BaseNode, to index: Int) {
    guard let currentIndex = self.index(of: child), currentIndex != index else {
      return
    }
    print(">>> Moving \(child) to \(index)")
    children?.remove(at: currentIndex)
    insert(child: child, at: index)
  }

  func index(of child: BaseNode) -> Int? {
    return children?.index(where: { $0 === child })
  }

  func computeLayout() -> SwiftBox.Layout {
    guard let root = root else {
      fatalError("Can't compute layout without a valid root node")
    }

    let children = root.currentInstance?.children?.map { $0.currentElement! }
    let workingElement = Element(root.currentElement!.type, root.currentElement!.properties, children)
    return Layout.perform(workingElement)
  }

  func performDiff(newElement: Element) {
    guard let currentInstance = currentInstance else {
      fatalError()
    }

    maybeUpdateProperties(instance: currentInstance, with: newElement)
    currentElement = newElement

    let children = newElement.children ?? []

    var currentChildren = (currentInstance.children ?? []).keyed { index, elm in
      computeKey(index, elm)
    }

    for (index, element) in children.enumerated() {
      let key = computeKey(index, element)
      guard let instance = currentChildren[key] else {
        append(element)
        continue
      }
      currentChildren.removeValue(forKey: key)

      if shouldReplace(instance, with: element) {
        replace(instance, with: element)
      } else {
        maybeUpdateProperties(instance: instance, with: element)
        move(child: instance, to: index)
        // TODO(mcudich): Make this more generic.
        if let node = instance as? Node {
          instance.performDiff(newElement: node.render())
        } else {
          instance.performDiff(newElement: element)
        }
      }
    }

    for (_, child) in currentChildren {
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
    // TODO(mcudich): Move this into shouldUpdate.
    if instance.properties == element.properties {
      return
    }
    print(">>> Updating properties on \(instance) with \(element.properties)")
    var instance = instance
    instance.properties = element.properties
  }

  func replace(_ instance: BaseNode, with element: Element) {
    let replacement = element.build(with: owner)
    guard let index = index(of: instance) else {
      fatalError()
    }
    print(">>> Replacing \(instance.currentElement) with \(element)")
    remove(child: instance)
    insert(child: replacement, at: index)
  }

  func append(_ element: Element) {
    print(">>> Adding \(element)")
    insert(child: element.build(with: owner))
  }

  func computeKey(_ index: Int, _ keyable: Keyable) -> String {
    return keyable.key ?? "\(index)"
  }
}

public protocol Node: BaseNode {
  static var propertyTypes: [String: ValidationType] { get }

  var state: Any? { get set }
  init(properties: [String: Any], owner: Node?)

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

  public var builtView: View? {
    return currentInstance?.builtView
  }

  public var children: [BaseNode]? {
    get {
      return currentInstance?.children
    }
    set {
      currentInstance?.children = newValue
    }
  }

  public func build() -> View {
    guard let currentInstance = currentInstance else {
      fatalError()
    }

    return currentInstance.build()
  }

  func update() {
    DispatchQueue.global(qos: .background).async {
      self.performDiff(newElement: self.render())
      let layout = self.computeLayout()

      DispatchQueue.main.async {
        let _ = self.build()
        self.root?.builtView?.applyLayout(layout: layout)
      }
    }
  }
}
