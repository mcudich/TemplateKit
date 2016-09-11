//
//  Details.swift
//  Example
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class Details: Component {
  public weak var owner: Component?
  public var currentInstance: Node?
  public var currentElement: Element?
  public var properties: [String : Any] {
    didSet {
      detailState.text = get("message") ?? ""
    }
  }
  public var state: Any? = State()
  public var context: Context?

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

  required init(properties: [String : Any], owner: Component?) {
    self.properties = properties
    self.owner = owner
  }

  func render() -> Element {
    return Element(ElementType.box, ["backgroundColor": get("backgroundColor") ?? UIColor.red], [
      Element(ElementType.text, ["text": "\(detailState.text) blah"]),
      Element(ElementType.text, ["text": "there", "onTap": #selector(Details.flipText)])
    ])
  }

  @objc func flipText() {
    updateState {
      detailState.text = "bye"
      return detailState
    }
  }
}

extension Details: PropertyTypeProvider {
  static var propertyTypes: [String : ValidationType] {
    return ["backgroundColor": Validation.color]
  }
}
