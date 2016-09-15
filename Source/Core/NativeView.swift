//
//  NativeView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol NativeView: View, MutablePropertyHolder, PropertyTypeProvider {
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

