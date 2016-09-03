import UIKit

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol Node: class, Layoutable {
  static var propertyTypes: [String: ValidationType] { get }

  var root: Node? { get set }
  var renderedView: UIView? { get set }

  var properties: [String: Any] { get }
  var state: Any? { get }
  var key: String? { get }
  var calculatedFrame: CGRect? { get set }
  var eventTarget: EventTarget { get }

  init(properties: [String: Any])

  func build() -> Node
  func render() -> UIView
  func sizeThatFits(_ size: CGSize) -> CGSize
  func sizeToFit(_ size: CGSize)
}

public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
  return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

public func ==(lhs: Node, rhs: Node) -> Bool {
  return lhs.properties == rhs.properties && lhs.key == rhs.key
}

extension Node {
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

  public var key: String? {
    return get("key")
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }

  public func render() -> UIView {
    return render(withView: nil)
  }

  public func update() {
    let _ = render(withView: root?.renderedView)
  }

  public func sizeThatFits(_ size: CGSize) -> CGSize {
    return build().sizeThatFits(size)
  }

  public func sizeToFit(_ size: CGSize) {
    if calculatedFrame == nil {
      calculatedFrame = CGRect.zero
    }
    calculatedFrame!.size = sizeThatFits(size)
  }

  fileprivate func applyFrame(to view: UIView) {
    if let calculatedFrame = calculatedFrame {
      view.frame = calculatedFrame
    }
  }

  fileprivate func applyCoreProperties(to view: UIView) {
    if let onTap: () -> Void = get("onTap") {
      eventTarget.tapHandler = onTap
      let recognizer = UITapGestureRecognizer(target: eventTarget, action: #selector(EventTarget.handleTap))
      view.addGestureRecognizer(recognizer)
    }
  }

  private func render(withView view: UIView?) -> UIView {
    let built = build()
    built.sizeToFit(flexSize)
    if let view = view {
      built.renderedView = view
    }

    let rendered = built.render()
    applyFrame(to: rendered)
    applyCoreProperties(to: rendered)

    root = built

    return rendered
  }
}

public class EventTarget: NSObject {
  var tapHandler: (() -> Void)?

  public func handleTap() {
    tapHandler?()
  }
}

public protocol LeafNode: Node {
  func applyProperties(to view: UIView)
  func buildView() -> UIView
}

extension LeafNode {
  public func build() -> Node {
    return self
  }

  public func render() -> UIView {
    let view = buildView()

    applyFrame(to: view)
    applyCoreProperties(to: view)
    applyProperties(to: view)

    renderedView = view

    return view
  }
}
