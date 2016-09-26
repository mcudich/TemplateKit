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
  public var selected: Bool?
  public var onTouchUpInside: Selector?

  public init() {}

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    for state in UIControlState.buttonStates {
      buttonStyle[state] = ButtonStyleProperties(properties, statePrefix: state.stringValue)
    }

    selected = properties.cast("selected")
    onTouchUpInside = properties.cast("onTouchUpInside")
  }
}

public func ==(lhs: ButtonProperties, rhs: ButtonProperties) -> Bool {
  return lhs.buttonStyle == rhs.buttonStyle && lhs.equals(otherViewProperties: rhs)
}

public struct ButtonState: State {

  public init() {}
}

public func ==(lhs: ButtonState, rhs: ButtonState) -> Bool {
  return false
}

public class Button: CompositeComponent<ButtonState, ButtonProperties, UIView> {
  public override func render() -> Element {
    var properties = BaseProperties()
    properties.layout = self.properties.layout
    
    return ElementData(ElementType.box, properties)
  }
}
