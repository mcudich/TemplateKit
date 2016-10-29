//
//  OrderedDictionary.swift
//  TwitterClientExample
//
//  Created by Matias Cudich on 10/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

// TODO(mcudich): Convert this to an enum so we can use indirect recursive boxing.
class OrderedDictionaryEntry<Key, Value> {
  typealias EntryType = OrderedDictionaryEntry<Key, Value>
  var key: Key?
  var value: Value?

  var previous: EntryType?
  var next: EntryType?

  init(key: Key?, value: Value?) {
    self.key = key
    self.value = value
  }
}

public struct OrderedDictionary<Key: Hashable, Value>: ExpressibleByDictionaryLiteral {
  fileprivate var items = Dictionary<Key, OrderedDictionaryEntry<Key, Value>>()
  fileprivate var head: OrderedDictionaryEntry<Key, Value>?

  public init() {}

  public init(dictionaryLiteral elements: (Key, Value)...) {
    for (key, value) in elements {
      self[key] = value
    }
  }

  public subscript (key: Key) -> Value? {
    get {
      return items[key]?.value
    }
    set (newValue) {
      if let newValue = newValue {
        _ = updateValue(newValue, forKey: key)
      } else {
        _ = removeValue(forKey: key)
      }
    }
  }

  public var first: (Key, Value)? {
    if let key = head?.key, let value = head?.value {
      return (key, value)
    }
    return nil
  }

  public var last: (Key, Value)? {
    if head?.previous == nil {
      return first
    }
    if let key = head?.previous?.key, let value = head?.previous?.value {
      return (key, value)
    }
    return nil
  }

  public var count: Int {
    return items.count
  }

  public var keys: LazyMapCollection<OrderedDictionary<Key, Value>, Key> {
    return self.lazy.map { (key, value) in
      return key
    }
  }

  public var values: LazyMapCollection<OrderedDictionary<Key, Value>, Value> {
    return self.lazy.map { (key, value) in
      return value
    }
  }

  public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
    if let existingValue = items[key] {
      existingValue.value = value
      return value
    } else {
      let previous = head?.previous ?? head
      let newValue = OrderedDictionaryEntry<Key, Value>(key: key, value: value)

      newValue.previous = previous
      previous?.next = newValue

      head?.previous = newValue
      if head == nil {
        head = newValue
      }
      return items.updateValue(newValue, forKey: key)?.value
    }
  }

  public mutating func removeValue(forKey key: Key) -> Value? {
    if let existingValue = items[key] {
      let previous = existingValue.previous
      let next = existingValue.next
      previous?.next = next
      next?.previous = previous
      if existingValue.key == head?.key {
        head = nil
      }
      return items.removeValue(forKey: key)?.value
    }
    return nil
  }
}

extension OrderedDictionary: Collection {
  public var startIndex: Int {
    return 0
  }

  public var endIndex: Int {
    return count
  }

  public func index(after i: Int) -> Int {
    return i + 1
  }

  public subscript(idx: Int) -> (Key, Value) {
    var count = 0
    var item = head
    while count < idx {
      item = item?.next
      count += 1
    }
    return (item!.key!, item!.value!)
  }
}

extension OrderedDictionary: Sequence {
  public func generate() -> AnyIterator<(Key, Value)> {
    var currentValue = head

    return AnyIterator() {
      let returnValue = currentValue
      currentValue = currentValue?.next

      if let value = returnValue, let k = value.key, let v = value.value {
        return (k, v)
      }
      return nil
    }
  }
}
