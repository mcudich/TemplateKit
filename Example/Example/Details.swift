//
//  Details.swift
//  Example
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class Details: Node {
  var properties: [String : Any]
  public var state: Any?
  public var eventTarget = EventTarget()


  required init(properties: [String : Any]) {
    self.properties = properties
  }

  func render() -> Element {
    return Element(ElementType.box, [:], [
      Element(ElementType.text, ["text": "hi"]),
      Element(ElementType.text)
    ])
  }
}
