//
//  DiffTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/30/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
import TemplateKit

struct FakeItem: Hashable {
  let value: Int

  var hashValue: Int {
    return value.hashValue
  }
}

func ==(lhs: FakeItem, rhs: FakeItem) -> Bool {
  return false
}

class DiffTests: XCTestCase {
  func testAdd() {
    let old = [
      IndexPath(row: 0, section: 0): 1,
      IndexPath(row: 1, section: 0): 2,
      IndexPath(row: 2, section: 0): 3
    ]
    let new = [
      IndexPath(row: 0, section: 0): 1,
      IndexPath(row: 1, section: 0): 2,
      IndexPath(row: 2, section: 0): 3,
      IndexPath(row: 3, section: 0): 4,
      IndexPath(row: 4, section: 0): 5
    ]
    let result = diff(old: old, new: new)
    XCTAssertEqual([IndexPath(row: 3, section: 0): 4, IndexPath(row: 4, section: 0): 5], result.add)
    XCTAssertEqual(0, result.remove.count)
    XCTAssertEqual(0, result.update.count)
    XCTAssertEqual(0, result.move.count)
  }

  func testRemove() {
    let old = [
      IndexPath(row: 0, section: 0): 1,
      IndexPath(row: 1, section: 0): 2,
      IndexPath(row: 2, section: 0): 3
    ]
    let new = [
      IndexPath(row: 3, section: 0): 4,
      IndexPath(row: 4, section: 0): 5
    ]
    let result = diff(old: old, new: new)
    XCTAssertEqual([IndexPath(row: 3, section: 0): 4, IndexPath(row: 4, section: 0): 5], result.add)
    XCTAssertEqual(3, result.remove.count)
    XCTAssertEqual(0, result.update.count)
    XCTAssertEqual(0, result.move.count)
  }

  func testMove() {
    let old = [
      IndexPath(row: 0, section: 0): 1,
      IndexPath(row: 1, section: 0): 2,
      IndexPath(row: 2, section: 0): 3
    ]
    let new = [
      IndexPath(row: 0, section: 0): 3,
      IndexPath(row: 1, section: 0): 1,
      IndexPath(row: 2, section: 0): 2
    ]
    let result = diff(old: old, new: new)
    XCTAssertEqual(0, result.add.count)
    XCTAssertEqual(0, result.remove.count)
    XCTAssertEqual(0, result.update.count)
    XCTAssertEqual(3, result.move.count)

    XCTAssertEqual(IndexPath(row: 1, section: 0), result.move[0].from)
    XCTAssertEqual(IndexPath(row: 2, section: 0), result.move[0].to)

    XCTAssertEqual(IndexPath(row: 2, section: 0), result.move[1].from)
    XCTAssertEqual(IndexPath(row: 0, section: 0), result.move[1].to)

    XCTAssertEqual(IndexPath(row: 0, section: 0), result.move[2].from)
    XCTAssertEqual(IndexPath(row: 1, section: 0), result.move[2].to)
  }

  func testUpdate() {
    let old = [
      IndexPath(row: 0, section: 0): FakeItem(value: 1),
      IndexPath(row: 1, section: 0): FakeItem(value: 2),
      IndexPath(row: 2, section: 0): FakeItem(value: 3)
    ]
    let new = [
      IndexPath(row: 0, section: 0): FakeItem(value: 1),
      IndexPath(row: 1, section: 0): FakeItem(value: 2),
      IndexPath(row: 2, section: 0): FakeItem(value: 3)
    ]
    let result = diff(old: old, new: new)
    XCTAssertEqual(0, result.add.count)
    XCTAssertEqual(0, result.remove.count)
    XCTAssertEqual(3, result.update.count)
    XCTAssertEqual(0, result.move.count)
  }
}
