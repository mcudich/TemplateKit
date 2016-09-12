//
//  Details.swift
//  Example
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct DetailsState: State {
  var text = "hi"
}

class Details: CompositeComponent<DetailsState> {
  public override var properties: [String : Any] {
    didSet {
      state.text = get("message") ?? ""
    }
  }

  override func render() -> Element {
    return Element(ElementType.box, ["backgroundColor": get("backgroundColor") ?? UIColor.red], [
      Element(ElementType.text, ["text": "\(state.text) blah"]),
      Element(ElementType.text, ["text": "there", "onTap": #selector(Details.flipText)])
    ])
  }

  @objc func flipText() {
    updateState {
      self.state.text = "bye"
      return self.state
    }
  }
}

extension Details: PropertyTypeProvider {
  static var propertyTypes: [String : ValidationType] {
    return ["backgroundColor": Validation.color]
  }
}
