//
//  ElementTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/12/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
@testable import TemplateKit

class FakeView: View {
  var frame: CGRect = CGRect.zero

  init() {
  }

  func applyLayout(layout: CSSLayout) {
  }
}

class FakeNode: Node {
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

class FakeComponent: CompositeComponent<EmptyState> {
  override func render() -> Element {
    return Element(FakeElementType.fakeNode)
  }
}

enum FakeElementType: Int, ElementRepresentable {
  case fakeNode
  case fakeComponent

  func make(_ properties: [String : Any], _ children: [Element]?, _ owner: Component?) -> Node {
    switch self {
    case .fakeNode:
      return FakeNode(properties: properties, owner: owner)
    case .fakeComponent:
      return FakeComponent(properties: properties, owner: owner)
    }
  }

  func equals(_ other: ElementRepresentable) -> Bool {
    if let other = other as? FakeElementType {
      return other.rawValue == rawValue
    }
    return false
  }
}

class ElementTests: XCTestCase {
  func testBuildNode() {
    let element = Element(FakeElementType.fakeNode)
    XCTAssert(FakeElementType.fakeNode.equals(element.type))

    let node = element.build(with: nil)
    XCTAssert(node is FakeNode)
    XCTAssertEqual(element, node.element!)

    let view = node.build()
    XCTAssert(view is FakeView)
  }

  func testBuildComponent() {
    let element = Element(FakeElementType.fakeComponent)
    let component = element.build(with: nil)
    XCTAssert(component is FakeComponent)
    XCTAssertNotNil(component.element)
    // This implies that render got called.
    XCTAssertNotNil(component.instance)
    XCTAssert(component.instance?.owner === component)
  }
}
