//
//  CountText.swift
//  Example
//
//  Created by Matias Cudich on 10/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct CountTextProperties: Properties, InheritingProperties {
  static var tagName = "CountText"

  var core = CoreProperties()
  var textStyle = TextStyleProperties()

  var count: String?

  init() {}

  init(_ properties: [String: Any]) {
    core = CoreProperties(properties)
    textStyle = TextStyleProperties(properties)

    count = properties.cast("count")
  }

  mutating func merge(_ other: CountTextProperties) {
    core.merge(other.core)
    textStyle.merge(other.textStyle)

    merge(&count, other.count)
  }
}

func ==(lhs: CountTextProperties, rhs: CountTextProperties) -> Bool {
  return lhs.count == rhs.count && lhs.equals(otherProperties: rhs)
}

class CountText: Component<EmptyState, CountTextProperties, UIView> {
  override func render() -> Template {
    var properties = TextProperties()
    properties.text = self.properties.count
    properties.textStyle = self.properties.textStyle

    return Template(text(properties))
  }
}
