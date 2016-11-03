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
  let eValue: Int

  var hashValue: Int {
    return value.hashValue
  }
}

func ==(lhs: FakeItem, rhs: FakeItem) -> Bool {
  return lhs.eValue == rhs.eValue
}

func ==(lhs: (from: Int, to: Int), rhs: (from: Int, to: Int)) -> Bool {
  return lhs.0 == rhs.0 && lhs.1 == rhs.1
}

extension DiffResult {
  var changeCount: Int {
    return insert.count + remove.count + update.count + move.count
  }
}

class DiffTests: XCTestCase {
  func testEmptyArrays() {
    let o = [Int]()
    let n = [Int]()
    let result = diff(o, n)
    XCTAssertFalse(result.hasChanges)
  }

  func testDiffingFromEmptyArray() {
    let o = [Int]()
    let n = [1]
    let result = diff(o, n)
    XCTAssertEqual(1, result.insert.count)
    XCTAssertEqual(1, result.changeCount)
  }

  func testDiffingToEmptyArray() {
    let o = [1]
    let n = [Int]()
    let result = diff(o, n)
    XCTAssertEqual(1, result.remove.count)
    XCTAssertEqual(1, result.changeCount)
  }

  func testSwapHasMoves() {
    let o = [1, 2]
    let n = [2, 1]
    let result = diff(o, n)
    let expectedMoves = [(from: 0, to: 1), (from: 1, to: 0)]
    let sortedMoves = result.move.sorted(by: { $0.from < $1.from })
    XCTAssert(expectedMoves.elementsEqual(sortedMoves, by: { $0.from == $1.from && $0.to == $1.to }))
    XCTAssertEqual(2, result.changeCount)
  }

  func testMovingTogether() {
    let o = [1, 2, 3, 3, 4]
    let n = [2, 3, 1, 3, 4]
    let result = diff(o, n)
    let sortedMoves = result.move.sorted(by: { $0.from < $1.from })
    XCTAssert((from: 0, to: 2) == sortedMoves[0])
    XCTAssert((from: 1, to: 0) == sortedMoves[1])
  }

  func testDiffingWordsFromPaper() {
    let os = "much writing is like snow , a mass of long words and phrases falls upon the relevant facts covering up the details ."
    let ns = "a mass of latin words falls upon the relevant facts like soft snow , covering up the details ."
    let o = os.components(separatedBy: " ")
    let n = ns.components(separatedBy: " ")
    let result = diff(o, n)
    XCTAssertEqual([0, 1, 2, 9, 11, 12], result.remove)
    XCTAssertEqual([3, 11], result.insert)
  }

  func testSwappedValuesHaveMoves() {
    let o = [1, 2, 3, 4]
    let n = [2, 4, 5, 3]
    let result = diff(o, n)
    let sortedMoves = result.move.sorted(by: { $0.from < $1.from })
    XCTAssert((from: 2, to: 3) == sortedMoves[0])
    XCTAssert((from: 3, to: 1) == sortedMoves[1])
  }

  func testUpdates() {
    let o = [
      FakeItem(value: 0, eValue: 0),
      FakeItem(value: 1, eValue: 1),
      FakeItem(value: 2, eValue: 2)
    ]
    let n = [
      FakeItem(value: 0, eValue: 1),
      FakeItem(value: 1, eValue: 2),
      FakeItem(value: 2, eValue: 3)
    ]
    let result = diff(o, n)
    XCTAssertEqual(3, result.update.count)
  }

  func testDeletionLeadingToInsertionDeletionMoves() {
    let o = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    let n = [0, 2, 3, 4, 7, 6, 9, 5, 10]
    let result = diff(o, n)
    XCTAssertEqual([1, 8], result.remove)
    XCTAssertEqual([6, 8], result.insert)
    let sortedMoves = result.move.sorted(by: { $0.from < $1.from })
    XCTAssert((from: 5, to: 7) == sortedMoves[0])
    XCTAssert((from: 7, to: 4) == sortedMoves[1])
  }

  func testMovingWithEqualityChanges() {
    let o = [
      FakeItem(value: 0, eValue: 0),
      FakeItem(value: 1, eValue: 1),
      FakeItem(value: 2, eValue: 2)
    ]
    let n = [
      FakeItem(value: 2, eValue: 3),
      FakeItem(value: 1, eValue: 1),
      FakeItem(value: 0, eValue: 0)
    ]
    let result = diff(o, n)
    XCTAssertEqual([0], result.update)
    let sortedMoves = result.move.sorted(by: { $0.from < $1.from })
    XCTAssert((from: 0, to: 2) == sortedMoves[0])
    XCTAssert((from: 2, to: 0) == sortedMoves[1])
  }

  func testDeletingEqualObjects() {
    let o = [0, 0, 0, 0]
    let n = [0, 0]
    let result = diff(o, n)
    XCTAssertEqual(2, o.count + result.insert.count - result.remove.count)
  }

  func testInsertingEqualObjects() {
    let o = [0, 0]
    let n = [0, 0, 0, 0]
    let result = diff(o, n)
    XCTAssertEqual(4, o.count + result.insert.count - result.remove.count)
  }

  func testInsertingWithOldArrayHavingMultipleCopies() {
    let o = [NSObject(), NSObject(), NSObject(), 49, 33, "cat", "cat", 0, 14] as [AnyHashable]
    var n = o
    n.insert("cat", at: 5)
    let result = diff(o, n)
    XCTAssertEqual(10, o.count + result.insert.count - result.remove.count)
  }
}
