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

    guard let currentElement = currentElement, let renderedView = renderedView else {
      // TODO(mcudich): Handle this.
      fatalError()
    }
    var newStack = [updatedElement]
    var currentStack = [currentElement]
    var viewStack = [renderedView]

    while !newStack.isEmpty && !currentStack.isEmpty && !viewStack.isEmpty {
      let new = newStack.removeFirst()
      let current = currentStack.removeFirst()
      let view = viewStack.removeFirst()
      if new != current {
        let newView = UIKitRenderer.make(new)
        let parentView = view.superview!
        let viewIndex = parentView.subviews.index(of: view)!
        view.removeFromSuperview()
        parentView.insertSubview(newView, at: viewIndex)
      } else {
        newStack.append(contentsOf: new.children ?? [])
        currentStack.append(contentsOf: current.children ?? [])
        viewStack.append(contentsOf: view.subviews)
      }
    }

    let layout = UIKitRenderer.layout(updatedElement)
    Layout.apply(layout, to: renderedView)
  }
}


