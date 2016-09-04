//
//  Box.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class Box: UIView {
  public init(children: [UIView]) {
    super.init(frame: CGRect.zero)

    children.forEach(addSubview)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
