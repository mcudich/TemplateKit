import UIKit

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol ElementRepresentable {
  // TODO(mcudich): Consider making this generic.
  func make(_ properties: [String: Any], _ children: [Element]?) -> BaseNode
}

public func ==(lhs: ElementRepresentable, rhs: ElementRepresentable) -> Bool {
  if let lhs = lhs as? ElementType, let rhs = rhs as? ElementType {
    return lhs == rhs
  }
  return false
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
      self.diff()

      DispatchQueue.main.async {
        self.build()
      }
    }
  }

  func diff() {
    let newElement = render()

    var newElements = [[newElement]]
    var currentInstances = [[currentInstance]]

    while !newElements.isEmpty && !currentInstances.isEmpty {
      let newList = newElements.removeFirst()
      let currentList = currentInstances.removeFirst()

      for (index, element) in newList.enumerated() {
        if let instance = currentList[index] {
          let elementType = element.type as! ElementType
          let instanceType = instance.currentElement!.type as! ElementType

          if case .node(let classType) = elementType, classType == type(of: instance) {
            print("deal with node update")
          } else if elementType != instanceType {
            replace(instance, with: element)
            continue
          } else if element.properties != instance.currentElement!.properties {
            updateProperties(instance, with: element)
          }
          newElements.append(element.children ?? [])
          currentInstances.append(instance.children ?? [])
        } else {
          // TODO(mcudich): Need a parent here.
          append(element)
        }
      }
    }
  }

  func replace(_ instance: BaseNode, with element: Element) {
    print("Replacing \(instance) with \(element)")
  }

  func updateProperties(_ instance: BaseNode, with element: Element) {
    print("Updating properties in \(instance) with \(element)")
    instance.properties = element.properties
  }

  func append(_ element: Element) {
    print("Adding \(element)")
  }

  func remove(_ instance: BaseNode) {
    print("Removing \(instance)")
  }
}

struct ChildList {
  var children: [BaseNode]
}
