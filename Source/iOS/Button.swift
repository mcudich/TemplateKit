//
//  Button.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension UIControlState: Hashable {
  var stringValue: String {
    switch self {
    case UIControlState.normal:
      return ""
    case UIControlState.disabled:
      return "disabled"
    case UIControlState.highlighted:
      return "highlighed"
    case UIControlState.selected:
      return "selected"
    default:
      fatalError("Unhandled control state")
    }
  }

  public var hashValue: Int {
    return stringValue.hashValue
  }

  static var buttonStates: [UIControlState] {
    return [UIControlState.normal, UIControlState.selected, UIControlState.highlighted, UIControlState.disabled]
  }
}

public struct ButtonStyleProperties: Equatable {
  var title: String?
  var titleColor: UIColor?
  var titleShadowColor: UIColor?
  var backgroundImage: UIImage?
  var image: UIImage?

  init(_ properties: [String : Any], statePrefix: String) {
    title = properties.cast(key(statePrefix, "title"))
    titleColor = properties.color(key(statePrefix, "titleColor"))
    titleShadowColor = properties.color(key(statePrefix, "titleShadowColor"))
    backgroundImage = properties.image(key(statePrefix, "backgroundImage"))
    image = properties.image(key(statePrefix, "image"))
  }

  private func key(_ prefix: String, _ propertyKey: String) -> String {
    var key = prefix
    key += prefix.isEmpty ? propertyKey : propertyKey.capitalized
    return key
  }
}

public func ==(lhs: ButtonStyleProperties, rhs: ButtonStyleProperties) -> Bool {
  return lhs.title == rhs.title && lhs.titleColor == rhs.titleColor && lhs.titleShadowColor == rhs.titleShadowColor && lhs.backgroundImage == rhs.backgroundImage && lhs.image == rhs.image
}

public struct ButtonProperties: ViewProperties {
  public var key: String?
  public var layout = LayoutProperties()
  public var style = StyleProperties()
  public var gestures = GestureProperties()

  public var buttonStyle = [UIControlState: ButtonStyleProperties]()
  public var selected: Bool = false
  public var enabled: Bool = true
  public var highlighted: Bool = false

  public init() {}

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    for state in UIControlState.buttonStates {
      buttonStyle[state] = ButtonStyleProperties(properties, statePrefix: state.stringValue)
    }

    if let selected: Bool = properties.cast("selected") {
      self.selected = selected
    }
    if let enabled: Bool = properties.cast("enabled") {
      self.enabled = enabled
    }
    if let highlighted: Bool = properties.cast("highlighted") {
      self.highlighted = highlighted
    }
  }
}

public func ==(lhs: ButtonProperties, rhs: ButtonProperties) -> Bool {
  return lhs.buttonStyle == rhs.buttonStyle && lhs.equals(otherViewProperties: rhs)
}

public struct ButtonState: State {
  var highlighted = false

  public init() {}
}

public func ==(lhs: ButtonState, rhs: ButtonState) -> Bool {
  return lhs.highlighted == rhs.highlighted
}

public class Button: CompositeComponent<ButtonState, ButtonProperties, UIView> {
  public override var properties: ButtonProperties {
    didSet {
      state.highlighted = properties.highlighted
    }
  }

  private var currentImage: UIImage? {
    return property { $0?.image }
  }

  private var currentTitle: String? {
    return property { $0?.title }
  }

  private var currentTitleColor: UIColor? {
    return property { $0?.titleColor }
  }

  public override func render() -> Element {
    var properties = BaseProperties()
    properties.layout = self.properties.layout
    properties.style = self.properties.style
    properties.gestures.onTap = #selector(Button.handleTap)
    properties.gestures.onPress = #selector(Button.handlePress)
    properties.gestures.onDoubleTap = #selector(Button.handleDoubleTap)

    var childElements = [Element]()
    if let image = currentImage {
      childElements.append(renderImage(with: image))
    }
    if let title = currentTitle {
      childElements.append(renderTitle(with: title))
    }

    return ElementData(ElementType.box, properties, childElements)
  }

  private func renderImage(with image: UIImage) -> Element {
    var properties = ImageProperties()
    properties.image = image

    return ElementData(ElementType.image, properties)
  }

  private func renderTitle(with title: String) -> Element {
    var properties = TextProperties()
    properties.textStyle.text = title
    properties.textStyle.color = currentTitleColor ?? .black

    return ElementData(ElementType.text, properties)
  }

  @objc private func handleTap() {
    updateComponentState(stateMutation: { $0.highlighted = false }) { [weak self] in
      guard self?.properties.enabled ?? true else {
        return
      }
      self?.performSelector(self?.properties.gestures.onTap)
    }
  }

  @objc private func handlePress() {
    updateComponentState { state in
      state.highlighted = true
    }
  }

  @objc private func handleDoubleTap() {
    updateComponentState(stateMutation: { $0.highlighted = false }) { [weak self] in
      guard self?.properties.enabled ?? true else {
        return
      }
      self?.performSelector(self?.properties.gestures.onDoubleTap)
    }
  }

  private func property<T>(handler: (ButtonStyleProperties?) -> T?) -> T? {
    if !properties.enabled {
      return handler(properties.buttonStyle[.disabled])
    }
    if state.highlighted {
      return handler(properties.buttonStyle[.highlighted])
    }
    if properties.selected {
      return handler(properties.buttonStyle[.selected])
    }
    return handler(properties.buttonStyle[.normal])
  }
}
