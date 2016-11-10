//
//  ItemModel.swift
//  SimpleTable
//
//  Created by Matias Cudich on 11/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

struct ItemModel: Hashable {
  let value: String

  var hashValue: Int {
    return value.hashValue
  }
}

func ==(lhs: ItemModel, rhs: ItemModel) -> Bool {
  return lhs.value == rhs.value
}
