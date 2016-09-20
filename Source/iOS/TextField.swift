//
//  TextField.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct TextFieldProperties: ViewProperties {
  public var key: String?
  public var layout: LayoutProperties?
  public var style: StyleProperties?
  public var gestures: GestureProperties?

  public var textStyle = TextStyleProperties([:])
  public var onChange: Selector?

  public init(_ dictionary: [String : Any]) {
  }

  public func toDictionary() -> [String : Any] {
    return [:]
  }
}

public func ==(lhs: TextFieldProperties, rhs: TextFieldProperties) -> Bool {
  return true
}

public class TextField: UITextField, NativeView {
  public static var propertyTypes: [String: ValidationType] {
    return commonPropertyTypes.merged(with: [
      "text": Validation.string,
      "fontName": Validation.string,
      "fontSize": Validation.float,
      "textColor": Validation.color,
      "textAlignment": TextValidation.textAlignment,
      "onChange": Validation.selector
    ])
  }

  public var eventTarget: AnyObject?

  public var properties = TextFieldProperties([:]) {
    didSet {
      applyProperties(properties: properties)
    }
  }

  fileprivate var lastSelectedRange: UITextRange?

  public required init() {
    super.init(frame: CGRect.zero)

    addTarget(self, action: #selector(TextField.onChange), for: .editingChanged)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func applyProperties(properties: TextFieldProperties) {
    applyCommonProperties(properties: properties)
    applyTextFieldProperties(properties: properties)
  }

  func applyTextFieldProperties(properties: TextFieldProperties) {
    guard let fontValue = UIFont(name: properties.textStyle.fontName, size: properties.textStyle.fontSize) else {
      fatalError("Attempting to use unknown font")
    }
    let attributes: [String : Any] = [
      NSFontAttributeName: fontValue,
      NSForegroundColorAttributeName: properties.textStyle.color
    ]
    attributedText = NSAttributedString(string: properties.textStyle.text, attributes: attributes)
    textAlignment = properties.textStyle.textAlignment

    selectedTextRange = lastSelectedRange
  }

  func onChange() {
    lastSelectedRange = selectedTextRange
    if let onChange = properties.onChange {
      let _ = eventTarget?.perform(onChange, with: self)
    }
  }
}
