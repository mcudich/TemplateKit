//
//  Todo.swift
//  Example
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class Todo: Component {
  public weak var owner: Component?
  public var currentInstance: Node?
  public var currentElement: Element?
  public var properties: [String : Any]
  public var state: Any? = State()

  struct State {
    var text = "blah"
  }

  private var todoState: State {
    get {
      return state as! State
    }
    set {
      state = newValue
    }
  }

  required init(properties: [String : Any], owner: Component?) {
    self.properties = properties
    self.owner = owner
  }

  func render() -> Element {
    return Element(ElementType.box, ["width": get("width")!], [
      Element(ElementType.image, ["url": URL(string: "https://farm9.staticflickr.com/8520/28696528773_0d0e2f08fb_m_d.jpg"), "width": Float(24), "height": Float(24)]),
      Element(ElementType.text, ["text": todoState.text, "onTap": #selector(Todo.random)]),
    ])
  }

  @objc func random() {
    updateState {
      todoState.text = "\(Int(arc4random()))"
      return todoState
    }
  }
}
