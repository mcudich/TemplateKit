//
//  NativeView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

public protocol Layoutable {
  func applyLayout(layout: SwiftBox.Layout)
}

public protocol PropertyTypeProvider {
  static var propertyTypes: [String: ValidationType] { get }
}

extension UIView: Layoutable {
  public func applyLayout(layout: SwiftBox.Layout) {
    Layout.apply(layout, to: self)
  }
}

public protocol View: Layoutable {
  var frame: CGRect { get set }
}

extension UIView: View {}

public protocol NativeView: View, PropertyHolder, PropertyTypeProvider {
  var eventTarget: AnyObject? { get set }
  var children: [View]? { get set }

  init()
}

extension NativeView {
  static var commonPropertyTypes: [String: ValidationType] {
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
      "onTap": Validation.any,
      "backgroundColor": Validation.color
    ]
  }

  static var propertyTypes: [String: ValidationType] {
    return commonPropertyTypes
  }
}

extension NativeView where Self: UIView {
  public var children: [View]? {
    set {
    }
    get { return nil }
  }

  func applyCommonProperties(properties: [String: Any]) {
    applyBackgroundColor(properties)
    applyTapHandler(properties)
  }

  private func applyBackgroundColor(_ properties: [String: Any]) {
    guard let backgroundColor: UIColor = get("backgroundColor") else {
      return
    }
    self.backgroundColor = backgroundColor
  }

  private func applyTapHandler(_ properties: [String: Any]) {
    guard let onTap: Selector = get("onTap") else {
      return
    }
    let recognizer = UITapGestureRecognizer(target: eventTarget, action: onTap)
    addGestureRecognizer(recognizer)
  }
}
