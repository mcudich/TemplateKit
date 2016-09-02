import UIKit

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol Node: class, Layoutable {
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
  public var key: String? {
    return get("key")
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }

  public func render() -> UIView {
    let built = build()
    built.sizeToFit(flexSize)

    let rendered = built.render()
    applyCoreProperties(to: rendered)

    root = built
    renderedView = rendered

    return rendered
  }

  public func update() {
    let built = build()
    built.sizeToFit(flexSize)
    built.renderedView = renderedView

    let rendered = built.render()
    applyCoreProperties(to: rendered)

    root = built
  }

  public func sizeThatFits(_ size: CGSize) -> CGSize {
    return build().sizeThatFits(size) ?? CGSize.zero
  }

  public func sizeToFit(_ size: CGSize) {
    let computedSize = sizeThatFits(size)
    if calculatedFrame == nil {
      calculatedFrame = CGRect.zero
    }
    calculatedFrame!.size = computedSize
  }

  fileprivate func applyCoreProperties(to view: UIView) {
    if let onTap: () -> Void = get("onTap") {
      eventTarget.tapHandler = onTap
      let recognizer = UITapGestureRecognizer(target: eventTarget, action: #selector(EventTarget.handleTap))
      view.addGestureRecognizer(recognizer)
    }
  }
}

public class EventTarget: NSObject {
  var tapHandler: (() -> Void)?

  public func handleTap() {
    tapHandler?()
  }
}

public protocol LeafNode: Node {
  func applyFrame(to view: UIView)
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

  public func applyFrame(to view: UIView) {
    if let calculatedFrame = calculatedFrame {
      view.frame = calculatedFrame
    }
  }
}
