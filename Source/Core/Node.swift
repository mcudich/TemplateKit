import UIKit

public protocol Node: class, PropertyHolder, Keyable {
  weak var owner: Component? { get set }
  var children: [Node]? { get set }
  var element: Element? { get set }
  var instance: Node? { get set }
  var builtView: View? { get }
  var cssNode: CSSNode? { get set }

  func build() -> View
  func shouldUpdate(nextProperties: [String: Any]) -> Bool
  func update(with newElement: Element)
  func computeLayout() -> CSSLayout

  func insert(child: Node, at index: Int?)
  func remove(child: Node)
  func index(of child: Node) -> Int?

  func willBuild()
  func didBuild()
  func willUpdate()
  func didUpdate()
  func willDetach()

  func performDiff()
}

public extension Node {
  public var instance: Node? {
    set {}
    get { return self }
  }

  var root: Node? {
    var current: Component? = owner ?? (self as? Component)
    while let currentOwner = current?.owner {
      current = currentOwner
    }
    return current
  }

  func insert(child: Node, at index: Int? = nil) {
    children?.insert(child, at: index ?? children!.endIndex)
    let _ = child.maybeBuildCSSNode()
    cssNode?.insertChild(child: child.maybeBuildCSSNode(), at: index ?? children!.endIndex - 1)
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
    guard let root = root, let rootCSSNode = root.instance?.maybeBuildCSSNode() else {
      fatalError("Can't compute layout without a valid root component")
    }

    return rootCSSNode.layout()
  }

  func update(with newElement: Element) {
    element = newElement

    if shouldUpdate(nextProperties: newElement.properties) {
      var node = self
      node.willUpdate()
      node.properties = newElement.properties
      node.updateCSSNode()
    }

    performDiff()
  }

  func performDiff() {
    diffChildren(newChildren: element?.children ?? [])
  }

  func diffChildren(newChildren: [Element]) {
    var currentChildren = (children ?? []).keyed { index, elm in
      computeKey(index, elm)
    }

    for (index, element) in newChildren.enumerated() {
      let key = computeKey(index, element)
      guard let instance = currentChildren[key] else {
        append(element)
        continue
      }
      currentChildren.removeValue(forKey: key)

      if shouldReplace(instance, with: element) {
        replace(instance, with: element)
      } else {
        move(child: instance, to: index)
        instance.update(with: element)
      }
    }

    for (_, child) in currentChildren {
      remove(child: child)
    }
  }

  func shouldUpdate(nextProperties: [String: Any]) -> Bool {
    return properties != nextProperties
  }

  func shouldReplace(_ instance: Node, with element: Element) -> Bool {
    if case ElementType.component(let classType) = element.type {
      return classType != type(of: instance)
    }

    return !element.type.equals(instance.element!.type)
  }

  func replace(_ instance: Node, with element: Element) {
    let replacement = element.build(with: owner)
    guard let index = index(of: instance) else {
      fatalError()
    }
    remove(child: instance)
    insert(child: replacement, at: index)
  }

  func append(_ element: Element) {
    insert(child: element.build(with: owner))
  }

  func computeKey(_ index: Int, _ keyable: Keyable) -> String {
    return keyable.key ?? "\(index)"
  }

  func willBuild() {}
  func didBuild() {}
  func willUpdate() {}
  func didUpdate() {}
  func willDetach() {}
}

func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
  return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

func !=(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
  return !NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
