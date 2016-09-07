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

  public init(properties: [String: Any], children: [UIView]) {
    super.init(frame: CGRect.zero)

    children.forEach(addSubview)

    applyCommonProperties(properties: properties)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
