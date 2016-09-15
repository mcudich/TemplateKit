//
//  Details.swift
//  Example
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct DetailsState: State, Equatable {
  var text = "hi"
  var bg = UIColor.red
}

func ==(lhs: DetailsState, rhs: DetailsState) -> Bool {
  return lhs.text == rhs.text && lhs.bg == rhs.bg
}

class Details: CompositeComponent<DetailsState> {
  public override var properties: [String : Any] {
    didSet {
      state.text = get("message") ?? ""
    }
  }

  override func render() -> Element {
//    return Element(ElementType.box, ["backgroundColor": state.bg], [
//      Element(ElementType.text, ["text": "\(state.text) blah"]),
//      Element(ElementType.text, ["text": "there", "onTap": #selector(Details.flipText)])
//    ])
    if state.text == "hi" {
      return Element(ElementType.text, ["text": "foo", "onTap": #selector(Details.flipText)])
    } else {
      return Element(ElementType.image, ["url": "https://farm9.staticflickr.com/8520/28696528773_0d0e2f08fb_m_d.jpg", "width": Float(100), "height": Float(100), "onTap": #selector(Details.flipText)])
    }
  }

  @objc func flipText() {
    updateComponentState { state in
      state.bg = .blue
      state.text = "blue!"
    }
  }
}

extension Details: PropertyTypeProvider {
  static var propertyTypes: [String : ValidationType] {
    return ["backgroundColor": Validation.color]
  }
}
