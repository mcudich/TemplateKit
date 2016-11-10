//
//  Item.swift
//  SimpleTable
//
//  Created by Matias Cudich on 11/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

import TemplateKit

struct ItemProperties: Properties {
  var core = CoreProperties()
  var item: String?

  init() {}

  init(_ properties: [String : Any]) {}

  mutating func merge(_ other: ItemProperties) {
    core.merge(other.core)
    merge(&item, other.item)
  }
}

func ==(lhs: ItemProperties, rhs: ItemProperties) -> Bool {
  return lhs.item == rhs.item && lhs.equals(otherProperties: rhs)
}

class Item: Component<EmptyState, ItemProperties, UIView> {
  static let templateURL = Bundle.main.url(forResource: "Item", withExtension: "xml")!

  override func render() -> Template {
    return render(Item.templateURL)
  }
}
