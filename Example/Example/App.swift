//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class App: Node {
  var root: Node?
  var renderedView: UIView?
  var properties: [String : Any]
  public var state: Any?
  var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  required init(properties: [String : Any]) {
    self.properties = properties
  }

  func build() -> Node {
    return Box(properties: ["width": CGFloat(320), "height": CGFloat(500), "paddingTop": CGFloat(60)]) {
      [Counter(properties: [:]).build()]
    }
  }
}
