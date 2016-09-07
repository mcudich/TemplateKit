//
//  Box.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class Box: UIView, NativeView {
  public lazy var eventTarget = EventTarget()

  public var properties = [String : Any]() {
    didSet {
      applyCommonProperties(properties: properties)
    }
  }

  public var children: [NativeView]? {
    didSet {
      // TODO(mcudich): Be smarter about adding/removing/moving here.
      for view in subviews {
        view.removeFromSuperview()
      }

      for child in (children ?? []) {
        if let subview = child as? UIView {
          addSubview(subview)
        }
      }
    }
  }

  public required init() {
    super.init(frame: CGRect.zero)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
