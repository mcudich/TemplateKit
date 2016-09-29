//
//  Button.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct ButtonProperties: Properties {
  public var core = CoreProperties()

  public var titleStyle = TextStyleProperties()
  public var backgroundImage: UIImage?
  public var image: UIImage?
  public var selected: Bool?
  public var enabled: Bool?
  public var highlighted: Bool?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)

    titleStyle = TextStyleProperties(properties)
    selected = properties.cast("selected")
    enabled = properties.cast("enabled")
    highlighted = properties.cast("highlighted")
  }

  public mutating func merge(_ other: ButtonProperties) {
    core.merge(other.core)

    titleStyle.merge(other.titleStyle)

    merge(&selected, other.selected)
    merge(&enabled, other.enabled)
    merge(&highlighted, other.highlighted)
  }

  public func has(key: String, withValue value: String) -> Bool {
    switch key {
    case "selected":
      return selected == Bool.fromString(value)
    default:
      fatalError("This attribute is not yet supported")
    }
  }
}

public func ==(lhs: ButtonProperties, rhs: ButtonProperties) -> Bool {
  return lhs.titleStyle == rhs.titleStyle && lhs.backgroundImage == rhs.backgroundImage && lhs.image == rhs.image && lhs.selected == rhs.selected && lhs.enabled == rhs.enabled && lhs.highlighted == rhs.highlighted && lhs.equals(otherProperties: rhs)
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
      state.highlighted = properties.highlighted ?? false
    }
  }

  public override func render() -> Element {
    var properties = DefaultProperties()
    properties.core.layout = self.properties.core.layout
    properties.core.style = self.properties.core.style
    properties.core.gestures.onTap = #selector(Button.handleTap)
    properties.core.gestures.onPress = #selector(Button.handlePress)
    properties.core.gestures.onDoubleTap = #selector(Button.handleDoubleTap)

    var childElements = [Element]()
    if let _ = self.properties.image {
      childElements.append(renderImage())
    }
    if let _ = self.properties.titleStyle.text {
      childElements.append(renderTitle())
    }

    return ElementData(ElementType.box, properties, childElements)
  }

  private func renderImage() -> Element {
    var properties = ImageProperties()
    properties.image = self.properties.image

    return ElementData(ElementType.image, properties)
  }

  private func renderTitle() -> Element {
    var properties = TextProperties()
    properties.textStyle = self.properties.titleStyle

    return ElementData(ElementType.text, properties)
  }

  @objc private func handleTap() {
    updateComponentState(stateMutation: { $0.highlighted = false }) { [weak self] in
      guard self?.properties.enabled ?? true else {
        return
      }
      self?.performSelector(self?.properties.core.gestures.onTap)
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
      self?.performSelector(self?.properties.core.gestures.onDoubleTap)
    }
  }
}
