import UIKit

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol ElementRepresentable {
  // TODO(mcudich): Consider making this generic.
  func make(_ properties: [String: Any], _ children: [Element]?) -> UIView
}

public protocol Node: class {
  static var propertyTypes: [String: ValidationType] { get }

  var properties: [String: Any] { get }
  var state: Any? { get set }
  var key: String? { get }
  var currentElement: Element? { get set }
  var renderedView: UIView? { get set }

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

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }

  func update() {
    let updatedElement = UIKitRenderer.resolve(render())

    // Prerequisite: keep a map of elements to views inside the node so it's easy to look them up
    // and we don't need to traverse the UIView hierarchy inside the diff algorithm, and therefore
    // can move it to a background thread.
    //
    // Move through and queue up child lists. For each child list, walk through and check if
    // the current child is different from the new one for that index. If so, remove the current
    // one and insert the new one. If the new list has any left over, insert them all. As we walk
    // through each of these children, queue up additional child lists to look at for any *current*
    // nodes that are left over. If we completely remove a current node, that tree will be wholesale
    // replaced by the *new* node. If the new list is shorter than the current one, drop any extra
    // nodes.
    //
    // Difference check should be done in this order:
    // * Are the types different? If so, replace.
    // * Are the properties different? If so, mutate.
  }
}


