import UIKit

public protocol Node: class, PropertyHolder, Keyable {
  weak var owner: Component? { get set }
  var children: [Node]? { get set }
  var element: Element? { get set }
  var instance: Node? { get set }
  var builtView: View? { get }
  var cssNode: CSSNode? { get set }

  func build() -> View
  func computeLayout() -> CSSLayout

  func insert(child: Node, at index: Int?)
  func remove(child: Node)
  func index(of child: Node) -> Int?

  func shouldUpdate(nextProperties: [String: Any]) -> Bool
  func willBuild()
  func didBuild()
  func willUpdate()
  func didUpdate()
  func willDetach()
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
    child.maybeBuildCSSNode()
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

  func performDiff(newElement: Element) {
    guard let instance = instance else {
      fatalError()
    }

    maybeUpdateProperties(instance: instance, with: newElement)
    element = newElement

    let children = newElement.children ?? []

    var currentChildren = (instance.children ?? []).keyed { index, elm in
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
        if let componentInstance = instance as? Component {
          instance.performDiff(newElement: componentInstance.render())
        } else {
          instance.performDiff(newElement: element)
        }
      }
    }

    for (_, child) in currentChildren {
      remove(child: child)
    }
  }

  func shouldReplace(_ instance: Node, with element: Element) -> Bool {
    if case ElementType.component(let classType) = element.type {
      return classType != type(of: instance)
    }

    return !element.type.equals(instance.element!.type)
  }

  func maybeUpdateProperties(instance: Node, with element: Element) {
    if !instance.shouldUpdate(nextProperties: element.properties) {
      return
    }

    // Because we are hitting a non-class protocol property here, we must declare as var. Swift bug?
    var instance = instance

    instance.willUpdate()
    instance.properties = element.properties

    instance.updateCSSNode()
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

  func shouldUpdate(nextProperties: [String: Any]) -> Bool {
    return properties != nextProperties
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
