import UIKit

public protocol Node: class, Keyable {
  weak var owner: Node? { get set }
  weak var parent: Node? { get set }
  var context: Context? { get set }

  var children: [Node]? { get set }
  var cssNode: CSSNode? { get set }
  var type: ElementRepresentable { get }

  func build<V: View>() -> V
  func getBuiltView<V>() -> V?
  func update(with newElement: Element)
  func forceUpdate()
  func computeLayout() -> CSSLayout
  func buildCSSNode() -> CSSNode
  func updateCSSNode()
  func getContext() -> Context

  func willBuild()
  func didBuild()
  func willUpdate()
  func didUpdate()
  func willDetach()
}

public extension Node {
  func computeLayout() -> CSSLayout {
    return buildCSSNode().layout()
  }

  func shouldReplace(type: ElementRepresentable, with otherType: ElementRepresentable) -> Bool {
    return !type.equals(otherType)
  }

  func updateParent() {
    for child in (children ?? []) {
      child.parent = self
    }
  }

  func getContext() -> Context {
    guard let context = context ?? owner?.getContext() else {
      fatalError("No context available")
    }
    return context
  }

  func willBuild() {}
  func didBuild() {}
  func willUpdate() {}
  func didUpdate() {}
  func willDetach() {}
}

public protocol PropertyNode: Node {
  associatedtype PropertiesType: Properties

  var element: ElementData<PropertiesType> { get set }
  var properties: PropertiesType { get set }

  func shouldUpdate(nextProperties: PropertiesType) -> Bool
  func performDiff()
}

public extension PropertyNode {
  public var key: String? {
    get {
      return properties.core.identifier.key
    }
    set {
      properties.core.identifier.key = newValue
    }
  }

  var type: ElementRepresentable {
    return element.type
  }

  func update(with newElement: Element) {
    let newElement = newElement as! ElementData<PropertiesType>
    let nextProperties = newElement.properties
    let shouldUpdate = self.shouldUpdate(nextProperties: nextProperties)
    performUpdate(with: newElement, nextProperties: nextProperties, shouldUpdate: shouldUpdate)
  }

  func forceUpdate() {
    performUpdate(with: element, nextProperties: properties, shouldUpdate: true)
  }

  func performUpdate(with newElement: ElementData<PropertiesType>, nextProperties: PropertiesType, shouldUpdate: Bool) {
    element = newElement

    if properties != nextProperties {
      properties = nextProperties
      updateCSSNode()
    }

    if shouldUpdate {
      performDiff()
    }
  }

  // Nodes by default perform child diffs, regardless of whether they themselves updated. This
  // function can be overriden by nodes that want finer-grained control over whether their subtree
  // is evaluated.
  func performDiff() {
    diffChildren(newChildren: element.children ?? [])
  }

  // Nodes should always update by default.
  func shouldUpdate(nextProperties: PropertiesType) -> Bool {
    return true
  }

  private func diffChildren(newChildren: [Element]) {
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

      if shouldReplace(type: currentChild.type, with: element.type) {
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

  private func computeKey(_ index: Int, _ keyable: Keyable) -> String {
    return keyable.key ?? "\(index)"
  }

  private func insert(child: Node, at index: Int) {
    children?.insert(child, at: index)
    cssNode?.insertChild(child: child.buildCSSNode(), at: index)
  }

  private func remove(child: Node) {
    guard let index = index(of: child) else {
      return
    }
    child.willDetach()
    children?.remove(at: index)
    if let childNode = child.cssNode {
      cssNode?.removeChild(child: childNode)
    }
  }

  private func move(child: Node, to index: Int) {
    guard let currentIndex = self.index(of: child), currentIndex != index else {
      return
    }
    children?.remove(at: currentIndex)
    if let childNode = child.cssNode {
      cssNode?.removeChild(child: childNode)
    }
    insert(child: child, at: index)
  }

  private func index(of child: Node) -> Int? {
    return children?.index(where: { $0 === child })
  }

  private func replace(_ node: Node, with element: Element) {
    let replacement = element.build(with: owner, context: nil)
    let index = self.index(of: node)!
    remove(child: node)
    insert(child: replacement, at: index)
  }

  private func append(_ element: Element) {
    let child = element.build(with: owner, context: nil)
    children?.insert(child, at: children!.endIndex)
    cssNode?.insertChild(child: child.buildCSSNode(), at: children!.count - 1)
  }
}
