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
  public var children: [BaseNode]?
  public var currentInstance: BaseNode?
  public var currentElement: Element?
  public var properties: [String : Any]
  public var state: Any? = State()

  struct State {
    var text = "hi"
  }


  private var detailState: State {
    get {
      return state as! State
    }
    set {
      state = newValue
    }
  }

  required init(properties: [String : Any]) {
    self.properties = properties
  }

  func render() -> Element {
    return Element(ElementType.box, [:], [
      Element(ElementType.text, ["text": detailState.text]),
      Element(ElementType.text, ["text": "there", "onTap": flipText])
    ])
  }

  func flipText() {
    updateState {
      detailState.text = "bye"
      return detailState
    }
  }
}
