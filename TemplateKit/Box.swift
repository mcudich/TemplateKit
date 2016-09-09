//
//  Box.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class Box: UIView, NativeView {
  public static var propertyTypes: [String: ValidationType] {
    return commonPropertyTypes.merged(with: [
      "flexDirection": FlexboxValidation.flexDirection,
      "paddingTop": Validation.float,
      "paddingBottom": Validation.float,
      "paddingLeft": Validation.float,
      "paddingRight": Validation.float,
      "justification": FlexboxValidation.justification,
      "childAlignment": FlexboxValidation.childAlignment
    ])
  }

  public var eventTarget: AnyObject?

  public var properties = [String : Any]() {
    didSet {
      applyCommonProperties(properties: properties)
    }
  }

  public var children: [View]? {
    didSet {
      var pendingViews = Set(subviews)

      for (index, child) in (children ?? []).enumerated() {
        guard let childView = child as? UIView else {
          fatalError()
        }

        insertSubview(childView, at: index)
        pendingViews.remove(childView)
      }

      pendingViews.forEach { $0.removeFromSuperview() }
    }
  }

  public required init() {
    super.init(frame: CGRect.zero)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
