//
//  Diff.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/30/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct DiffResult<T> {
  public let add: [T]
  public let remove: [T]
  public let move: [(from: Int, to: Int)]
  public let update: [(existing: T, replacement: T)]
}

public func diff<T: Hashable>(old: [T], new: [T]) -> DiffResult<T> {
  var add = [T]()
  var remove = [T]()
  var move = [(from: Int, to: Int)]()
  var update = [(existing: T, replacement: T)]()

  var current = [AnyHashable: (index: Int, item: T)]()
  for (index, item) in old.enumerated() {
    current[item.hashValue] = (index: index, item: item)
  }

  for (index, item) in new.enumerated() {
    // The new item doesn't exist in the old list, so add it.
    guard let oldItem = current[item.hashValue] else {
      add.append(item)
      continue
    }

    // We're either going to be moving or updating this item, so remove it from the list of items to remove.
    current.removeValue(forKey: item.hashValue)

    // If the item exists in the list, but is at a different index than we'd expect, we need to move it.
    if index != oldItem.index {
      move.append((from: oldItem.index, to: index))
    }
    // If the items aren't equal (but do share a hash value), then that means that we need to update the old one with the new one. It is valid to need to both move and update an item.
    if oldItem.item != item {
      update.append((existing: oldItem.item, replacement: item))
    }
  }

  // Finally, remove all items that didn't appear in the new list.
  for (_, item) in current {
    remove.append(item.item)
  }

  return DiffResult(add: add, remove: remove, move: move, update: update)
}
