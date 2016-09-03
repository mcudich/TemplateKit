//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 9/2/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class Message: Node {
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
    do {
      return try TemplateService.shared.node(withLocation: Bundle.main.url(forResource: "Message", withExtension: "xml")!, properties: properties)
    } catch {
      fatalError("Missing node!")
    }
  }
}
