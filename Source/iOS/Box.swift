//
//  Box.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class Box: UIView, NativeView, ContainerView {
  public weak var eventTarget: AnyObject?

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

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    touchesBegan()
  }
}
