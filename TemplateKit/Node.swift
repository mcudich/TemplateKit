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
  var state: Any? { get }
  var key: String? { get }
  var eventTarget: EventTarget { get }

  init(properties: [String: Any])

  func render() -> Element
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

  public func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize.zero
  }

  public func sizeToFit(_ size: CGSize) {
//    if calculatedFrame == nil {
//      calculatedFrame = CGRect.zero
//    }
//    calculatedFrame!.size = sizeThatFits(size)
  }

  fileprivate func applyFrame(to view: UIView) {
//    if let calculatedFrame = calculatedFrame {
//      view.frame = calculatedFrame
//    }
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
