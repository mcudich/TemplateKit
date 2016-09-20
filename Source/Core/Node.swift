import UIKit

public protocol Node: class, Keyable {
  weak var owner: Node? { get set }
  weak var parent: Node? { get set }
  var context: Context? { get set }

  var children: [Node]? { get set }
  var element: Element { get set }
  var cssNode: CSSNode? { get set }
  var key: String? { get }

  init(element: Element, properties: [String: Any], children: [Node]?, owner: Node?)

  func build<V: View>() -> V
  func update(with newElement: Element)
  func computeLayout() -> CSSLayout
  func buildCSSNode() -> CSSNode
  func updateCSSNode()

  func insert(child: Node, at index: Int)
  func remove(child: Node)
  func index(of child: Node) -> Int?

  func willBuild()
  func didBuild()
  func willUpdate()
  func didUpdate()
  func willDetach()
}

public protocol PropertyNode: Node {
  associatedtype PropertiesType: Properties

  var properties: PropertiesType { get set }

  func shouldUpdate(nextProperties: PropertiesType) -> Bool
  func performDiff()
}

public extension Node {
  func insert(child: Node, at index: Int) {
    children?.insert(child, at: index)
    cssNode?.insertChild(child: child.buildCSSNode(), at: index)
  }

  func remove(child: Node) {
    guard let index = index(of: child) else {
      return
    }
    child.willDetach()
    children?.remove(at: index)
    if let childNode = child.cssNode {
      cssNode?.removeChild(child: childNode)
    }
  }

  func move(child: Node, to index: Int) {
    guard let currentIndex = self.index(of: child), currentIndex != index else {
      return
    }
    children?.remove(at: currentIndex)
    if let childNode = child.cssNode {
      cssNode?.removeChild(child: childNode)
    }
    insert(child: child, at: index)
  }

  func index(of child: Node) -> Int? {
    return children?.index(where: { $0 === child })
  }

  func computeLayout() -> CSSLayout {
    return buildCSSNode().layout()
  }

  func shouldReplace(_ node: Node, with element: Element) -> Bool {
    return !element.type.equals(node.element.type)
  }

  func replace(_ node: Node, with element: Element) {
    let replacement = element.build(with: owner)
    let index = self.index(of: node)!
    remove(child: node)
    insert(child: replacement, at: index)
  }

  func append(_ element: Element) {
    let child = element.build(with: owner)
    children?.insert(child, at: children!.endIndex)
    cssNode?.insertChild(child: child.buildCSSNode(), at: children!.count - 1)
  }

  func computeKey(_ index: Int, _ keyable: Keyable) -> String {
    return keyable.key ?? "\(index)"
  }

  func updateParent() {
    for child in (children ?? []) {
      child.parent = self
    }
  }

  func willBuild() {}
  func didBuild() {}
  func willUpdate() {}
  func didUpdate() {}
  func willDetach() {}
}

public extension PropertyNode {
  var key: String? {
    return properties.key
  }

  func update(with newElement: Element) {
    element = newElement

    let nextProperties = PropertiesType(newElement.properties)
    if shouldUpdate(nextProperties: nextProperties) {
      willUpdate()
      properties = nextProperties
      updateCSSNode()
      performDiff()
    }
  }

  func performDiff() {
    diffChildren(newChildren: element.children ?? [])
  }

  func diffChildren(newChildren: [Element]) {
    var currentChildren = (children ?? []).keyed { index, elm in
      computeKey(index, elm)
    }

    for (index, element) in newChildren.enumerated() {
      let key = computeKey(index, element)
      guard let currentChild = currentChildren[key] else {
        append(element)
        continue
      }
      currentChildren.removeValue(forKey: key)

      if shouldReplace(currentChild, with: element) {
        replace(currentChild, with: element)
      } else {
        move(child: currentChild, to: index)
        currentChild.update(with: element)
      }
    }

    for (_, child) in currentChildren {
      remove(child: child)
    }
  }

  func shouldUpdate(nextProperties: PropertiesType) -> Bool {
    return properties != nextProperties
  }
}

func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
  return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

func !=(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
  return !NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
