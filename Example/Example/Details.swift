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
  var bg = UIColor.red
}

class Details: CompositeComponent<DetailsState> {
  public override var properties: [String : Any] {
    didSet {
      state.text = get("message") ?? ""
    }
  }

  override func render() -> Element {
    return Element(ElementType.box, ["backgroundColor": state.bg], [
      Element(ElementType.text, ["text": "\(state.text) blah"]),
      Element(ElementType.text, ["text": "there", "onTap": #selector(Details.flipText)])
    ])
  }

  @objc func flipText() {
    updateState {
      self.state.bg = .blue
      self.state.text = "blue!"
      return self.state
    }
  }
}

extension Details: PropertyTypeProvider {
  static var propertyTypes: [String : ValidationType] {
    return ["backgroundColor": Validation.color]
  }
}
