//
//  Box.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class Box: UIView, NativeView {
  public weak var eventTarget: AnyObject?
  public lazy var eventRecognizers = [AnyObject]()

  public var properties = DefaultProperties() {
    didSet {
      applyCoreProperties()
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
