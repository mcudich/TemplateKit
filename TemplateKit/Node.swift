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
  var children: [BaseNode]? { get }
  var currentElement: Element? { get set }
  var renderedView: NativeView? { get }

  func build() -> NativeView
}

public protocol Node: BaseNode {
  static var propertyTypes: [String: ValidationType] { get }

  var state: Any? { get set }
  var key: String? { get }
  var currentInstance: BaseNode? { get set }

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

  public var renderedView: NativeView? {
    return currentInstance?.renderedView
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
      self.performDiff()

      DispatchQueue.main.async {
        self.build()
      }
    }
  }

  func performDiff() {
    let newElement = render()

    var currentParent: BaseNode!
    var newElements = [[newElement]]
    var currentInstances = [[currentInstance]]

    while !newElements.isEmpty && !currentInstances.isEmpty {
      let newList = newElements.removeFirst()
      let currentList = currentInstances.removeFirst()

      for (index, element) in newList.enumerated() {
        if let instance = currentList[index] {
          if shouldReplace(instance, with: element) {
            replace(instance, with: element)
          } else {
            maybeUpdateProperties(instance, with: element)

            currentParent = instance
            newElements.append(element.children ?? [])
            currentInstances.append(instance.children ?? [])
          }
        } else {
          append(element, to: currentParent)
        }
      }

      if currentList.count > newList.count {
        for index in newList.count..<currentList.count {
          remove(currentList[index]!, from: currentParent)
        }
      }
    }
  }

  func shouldReplace(_ instance: BaseNode, with element: Element) -> Bool {
    if case ElementType.node(let classType) = element.type, classType != type(of: instance) || !element.type.equals(instance.currentElement!.type) {
      return true
    }
    return false
  }

  func replace(_ instance: BaseNode, with element: Element) {
    let replacement = element.type.make(element.properties, element.children)
    print("Replacing \(instance) with \(replacement)")
  }

  func maybeUpdateProperties(_ instance: BaseNode, with element: Element) {
    if instance.properties == element.properties {
      return
    }
    instance.properties = element.properties
    if let node = instance as? Node {
      node.performDiff()
    }
  }

  func append(_ element: Element, to parent: BaseNode) {
    let addition = element.type.make(element.properties, element.children)
    print("Adding \(element)")
  }

  func remove(_ instance: BaseNode, from parent: BaseNode) {
    print("Removing \(instance)")
  }
}

struct ChildList {
  var children: [BaseNode]
}
