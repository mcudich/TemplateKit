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

  func build(completion: (Node) -> Void)
  func render(completion: @escaping (UIView) -> Void)
  func sizeThatFits(_ size: CGSize, completion: (CGSize) -> Void)
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

  public func render(completion: @escaping (UIView) -> Void) {
    build { root in
      self.root = root
      root.sizeToFit(flexSize)
      DispatchQueue.main.async {
        root.render { view in
          self.renderedView = view
          self.applyCoreProperties(to: view)
          completion(view)
        }
      }
    }
  }

  public func update() {
    build { root in
      self.root = root
      root.sizeToFit(flexSize)
      root.renderedView = renderedView
      root.render { view in
        self.applyCoreProperties(to: view)
      }
    }
  }

  public func sizeThatFits(_ size: CGSize, completion: (CGSize) -> Void) {
    build { root in
      root.sizeThatFits(size, completion: completion)
    }
  }

  public func sizeToFit(_ size: CGSize) {
    sizeThatFits(size) { computedSize in
      if calculatedFrame == nil {
        calculatedFrame = CGRect.zero
      }
      calculatedFrame!.size = computedSize
    }
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
  public func build(completion: (Node) -> Void) {
    completion(self)
  }

  public func render(completion: @escaping (UIView) -> Void) {
    let view = buildView()

    applyFrame(to: view)
    applyCoreProperties(to: view)
    applyProperties(to: view)

    renderedView = view

    return completion(view)
  }

  public func applyFrame(to view: UIView) {
    if let calculatedFrame = calculatedFrame {
      view.frame = calculatedFrame
    }
  }
}
