//
//  Diff.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/30/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct DiffResult<T> {
  public let add: [IndexPath: T]
  public let remove: [IndexPath]
  public let move: [(from: IndexPath, to: IndexPath)]
  public let update: [IndexPath]
}

public func diff<T: Hashable>(old: [IndexPath: T], new: [IndexPath: T]) -> DiffResult<T> {
  var add = [IndexPath: T]()
  var remove = [IndexPath]()
  var move = [(from: IndexPath, to: IndexPath)]()
  var update = [IndexPath]()

  var current = [AnyHashable: (index: IndexPath, item: T)]()
  for (indexPath, item) in old {
    current[item.hashValue] = (index: indexPath, item: item)
  }

  for (indexPath, item) in new {
    // The new item doesn't exist in the old list, so add it.
    guard let oldItem = current[item.hashValue] else {
      add[indexPath] = item
      continue
    }

    // We're either going to be moving or updating this item, so remove it from the list of items to remove.
    current.removeValue(forKey: item.hashValue)

    // If the item exists in the list, but is at a different index than we'd expect, we need to move it.
    if indexPath != oldItem.index {
      move.append((from: oldItem.index, to: indexPath))
    }
    // If the items aren't equal (but do share a hash value), then that means that we need to update the old one with the new one. It is valid to need to both move and update an item.
    if oldItem.item != item {
      update.append(indexPath)
    }
  }

  // Finally, remove all items that didn't appear in the new list.
  for (_, item) in current {
    remove.append(item.index)
  }

  return DiffResult(add: add, remove: remove, move: move, update: update)
}
