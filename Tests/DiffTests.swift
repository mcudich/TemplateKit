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
    let old = [1, 2, 3]
    let new = [1, 2, 3, 4, 5]
    let result = diff(old: old, new: new)
    XCTAssertEqual([4, 5], result.add)
    XCTAssertEqual(0, result.remove.count)
    XCTAssertEqual(0, result.update.count)
    XCTAssertEqual(0, result.move.count)
  }

  func testRemove() {
    let old = [1, 2, 3]
    let new = [4, 5]
    let result = diff(old: old, new: new)
    XCTAssertEqual([4, 5], result.add)
    XCTAssertEqual(3, result.remove.count)
    XCTAssertEqual(0, result.update.count)
    XCTAssertEqual(0, result.move.count)
  }

  func testMove() {
    let old = [1, 2, 3]
    let new = [3, 1, 2]
    let result = diff(old: old, new: new)
    XCTAssertEqual(0, result.add.count)
    XCTAssertEqual(0, result.remove.count)
    XCTAssertEqual(0, result.update.count)
    XCTAssertEqual(3, result.move.count)

    XCTAssertEqual(2, result.move[0].from)
    XCTAssertEqual(0, result.move[0].to)
    XCTAssertEqual(0, result.move[1].from)
    XCTAssertEqual(1, result.move[1].to)
    XCTAssertEqual(1, result.move[2].from)
    XCTAssertEqual(2, result.move[2].to)
  }

  func testUpdate() {
    let old = [FakeItem(value: 1), FakeItem(value: 2), FakeItem(value: 3)]
    let new = [FakeItem(value: 1), FakeItem(value: 2), FakeItem(value: 3)]
    let result = diff(old: old, new: new)
    XCTAssertEqual(0, result.add.count)
    XCTAssertEqual(0, result.remove.count)
    XCTAssertEqual(3, result.update.count)
    XCTAssertEqual(0, result.move.count)
  }
}
