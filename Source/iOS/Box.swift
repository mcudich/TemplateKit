//
//  Box.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class Box: UIView, NativeView, ContainerView {
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

  public var children: [View] {
    get {
      return subviews
    }
    set {
      var viewsToRemove = Set(subviews)

      for (index, child) in newValue.enumerated() {
        let childView = child as! UIView
        insertSubview(childView, at: index)
        viewsToRemove.remove(childView)
      }

      viewsToRemove.forEach { $0.removeFromSuperview() }
    }
  }

  public var properties = BaseProperties([:]) {
    didSet {
      applyCommonProperties()
    }
  }

  public required init() {
    super.init(frame: CGRect.zero)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
