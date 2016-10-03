//
//  TextField.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct TextFieldProperties: Properties, FocusableProperties, EnableableProperties {
  public var core = CoreProperties()

  public var textStyle = TextStyleProperties()
  public var text: String?
  public var onChange: Selector?
  public var onSubmit: Selector?
  public var onBlur: Selector?
  public var onFocus: Selector?
  public var placeholder: String?
  public var enabled: Bool?
  public var focused: Bool?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)
    textStyle = TextStyleProperties(properties)

    text = properties.cast("text")
    onChange = properties.cast("onChange")
    onSubmit = properties.cast("onSubmit")
    onBlur = properties.cast("onBlur")
    onFocus = properties.cast("onFocus")
    placeholder = properties.cast("placeholder")
    enabled = properties.cast("enabled")
    focused = properties.cast("focused")
  }

  public mutating func merge(_ other: TextFieldProperties) {
    core.merge(other.core)
    textStyle.merge(other.textStyle)

    merge(&text, other.text)
    merge(&onChange, other.onChange)
    merge(&onSubmit, other.onSubmit)
    merge(&onBlur, other.onBlur)
    merge(&onFocus, other.onFocus)
    merge(&placeholder, other.placeholder)
    merge(&enabled, other.enabled)
    merge(&focused, other.focused)
  }
}

public func ==(lhs: TextFieldProperties, rhs: TextFieldProperties) -> Bool {
  return lhs.textStyle == rhs.textStyle && lhs.onChange == rhs.onChange && lhs.onSubmit == rhs.onSubmit && lhs.placeholder == rhs.placeholder && lhs.enabled == rhs.enabled && lhs.equals(otherProperties: rhs)
}

public class TextField: UITextField, NativeView {
  public weak var eventTarget: AnyObject?

  public var properties = TextFieldProperties() {
    didSet {
      applyProperties()
    }
  }

  private var lastSelectedRange: UITextRange?

  public required init() {
    super.init(frame: CGRect.zero)

    addTarget(self, action: #selector(TextField.onChange), for: .editingChanged)
    addTarget(self, action: #selector(TextField.onSubmit), for: .editingDidEndOnExit)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func applyProperties() {
    applyCoreProperties()
    applyTextFieldProperties()
  }

  func applyTextFieldProperties() {
    let fontName = properties.textStyle.fontName ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
    let fontSize = properties.textStyle.fontSize ?? UIFont.systemFontSize
    guard let fontValue = UIFont(name: fontName, size: fontSize) else {
      fatalError("Attempting to use unknown font")
    }
    let attributes: [String : Any] = [
      NSFontAttributeName: fontValue,
      NSForegroundColorAttributeName: properties.textStyle.color ?? .black
    ]

    selectedTextRange = lastSelectedRange
    tintColor = .black

    attributedText = NSAttributedString(string: properties.text ?? "", attributes: attributes)
    textAlignment = properties.textStyle.textAlignment ?? .natural
    placeholder = properties.placeholder
    isEnabled = properties.enabled ?? true
    if properties.focused ?? false {
      let _ = becomeFirstResponder()
    }
  }

  func onChange() {
    lastSelectedRange = selectedTextRange
    if let onChange = properties.onChange {
      let _ = eventTarget?.perform(onChange, with: self)
    }
  }

  func onSubmit() {
    if let onSubmit = properties.onSubmit {
      let _ = eventTarget?.perform(onSubmit, with: self)
    }
  }

  public override func becomeFirstResponder() -> Bool {
    if let onFocus = properties.onFocus {
      let _ = eventTarget?.perform(onFocus, with: self)
    }
    return super.becomeFirstResponder()
  }

  public override func resignFirstResponder() -> Bool {
    if let onBlur = properties.onBlur {
      let _ = eventTarget?.perform(onBlur, with: self)
    }
    return super.resignFirstResponder()
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    touchesBegan()
  }
}
