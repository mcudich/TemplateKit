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

public class Button: UIButton, NativeView {
  public weak var eventTarget: AnyObject?

  public var properties = ButtonProperties([:]) {
    didSet {
      applyProperties()
    }
  }

  public required init() {
    super.init(frame: CGRect.zero)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func applyProperties() {
    applyCommonProperties()
    applyButtonProperties()
  }

  func handleTouchUpInside() {
    isSelected = !isSelected
    if let onTouchUpInside = properties.onTouchUpInside {
      let _ = eventTarget?.perform(onTouchUpInside, with: self)
    }
  }

  func applyButtonProperties() {
    for state in UIControlState.buttonStates {
      let stateProperties = properties.buttonStyle[state]

      setTitle(stateProperties?.title, for: state)
      setTitleColor(stateProperties?.titleColor, for: state)
      setTitleShadowColor(stateProperties?.titleShadowColor, for: state)
      setBackgroundImage(stateProperties?.backgroundImage, for: state)
      setImage(stateProperties?.image, for: state)
    }
    if let _ = properties.onTouchUpInside {
      addTarget(self, action: #selector(Button.handleTouchUpInside), for: .touchUpInside)
    }
    isSelected = properties.selected ?? false
  }
}
