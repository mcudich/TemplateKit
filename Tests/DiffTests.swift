//
//  DiffTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/14/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
@testable import TemplateKit

class DiffableFakeNode: Node {
  var owner: Component?
  var children: [Node]?
  var element: Element?
  var builtView: View?
  var cssNode: CSSNode?
  var properties: [String : Any]

  init(properties: [String: Any], owner: Component?) {
    self.properties = properties
    self.owner = owner
  }

  func build() -> View {
    return FakeView()
  }
}

class DiffTests: XCTestCase {
  func testUpdateRootNodeProperties() {
    let tree = Element(ElementType.box, ["foo": "bar"])
    let instance = tree.build(with: nil)
    let newTree = Element(ElementType.box, ["foo": "baz"])
    instance.performDiff(newElement: newTree)
    XCTAssertEqual(instance.get("foo"), "baz")
  }

  func testUpdateChildNodeProperties() {
    let tree = Element(ElementType.box, [:], [
      Element(ElementType.box, ["foo": "bar"]),
      Element(ElementType.box)
    ])
    let instance = tree.build(with: nil)
    let newTree = Element(ElementType.box, [:], [
      Element(ElementType.box, ["foo": "baz"]),
      Element(ElementType.box)
    ])
    instance.performDiff(newElement: newTree)
    let diffedChild = instance.children!.first!
    XCTAssertEqual(diffedChild.get("foo"), "baz")
  }
}
