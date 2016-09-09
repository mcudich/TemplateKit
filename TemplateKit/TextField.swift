//
//  TextField.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

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

  public var properties = [String : Any]() {
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

  func applyProperties(properties: [String: Any]) {
    applyCommonProperties(properties: properties)
    applyTextFieldProperties(properties: properties)
  }

  func applyTextFieldProperties(properties: [String: Any]) {
    let defaultFontName = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
    let fontValue = UIFont(name: get("fontName") ?? defaultFontName, size: get("fontSize") ?? UIFont.systemFontSize)
    let attributes: [String: Any] = [
      NSFontAttributeName: fontValue!,
      NSForegroundColorAttributeName: get("textColor") ?? UIColor.black
    ]
    attributedText = NSAttributedString(string: get("text") ?? "", attributes: attributes)
    textAlignment = get("textAlignment") ?? .natural

    selectedTextRange = lastSelectedRange
  }

  func onChange() {
    lastSelectedRange = selectedTextRange
    if let onChange: Selector = get("onChange") {
      eventTarget?.perform(onChange, with: self)
    }
  }
}

extension TextField: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

    return true
  }
}
