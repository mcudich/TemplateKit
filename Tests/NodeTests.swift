//
//  NodeTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/24/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
@testable import TemplateKit

extension NativeNode: Equatable {}
public func ==<T: NativeView>(lhs: NativeNode<T>, rhs: NativeNode<T>) -> Bool {
  return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

class NodeTests: XCTestCase {
  func testBuild() {
    let child1 = box(DefaultProperties(["width": Float(50)]))
    let child2 = box(DefaultProperties(["width": Float(10)]))
    let child3 = image(ImageProperties(["width": Float(30)]))

    let tree = box(DefaultProperties(), [child1, child2, child3])
    let node = tree.build(withOwner: nil, context: nil) as? NativeNode<Box>
    let child1Node = node?.children?[0] as? NativeNode<Box>
    let child2Node = node?.children?[1] as? NativeNode<Box>
    let child3Node = node?.children?[2] as? NativeNode<Image>

    XCTAssertEqual(50, child1Node?.properties.core.layout.width)
    XCTAssertEqual(10, child2Node?.properties.core.layout.width)
    XCTAssertEqual(30, child3Node?.properties.core.layout.width)

    XCTAssertNotNil(child1Node?.parent)
    XCTAssertEqual(3, node?.children?.count)
  }

  func testUpdateChildProperties() {
    let child1 = box(DefaultProperties(["width": Float(50)]))
    let child2 = box(DefaultProperties(["width": Float(10)]))
    let child3 = image(ImageProperties(["width": Float(30)]))

    let tree = box(DefaultProperties(), [child1, child2, child3])
    let node = tree.build(withOwner: nil, context: nil) as? NativeNode<Box>

    let newChild1 = box(DefaultProperties(["width": Float(150)]))
    let newTree = box(DefaultProperties(), [newChild1, child2, child3])
    let child1Node = node?.children?[0] as? NativeNode<Box>

    node?.update(with: newTree)
    XCTAssertEqual(150, child1Node?.properties.core.layout.width)
    XCTAssertEqual(node?.children?[0] as? NativeNode<Box>, child1Node)
  }

  func testReplaceChild() {
    let child1 = box(DefaultProperties(["width": Float(50)]))
    let child2 = box(DefaultProperties(["width": Float(10)]))
    let child3 = image(ImageProperties(["width": Float(30)]))

    let tree = box(DefaultProperties(), [child1, child2, child3])
    let node = tree.build(withOwner: nil, context: nil) as? NativeNode<Box>
    let newChild1 = text(TextProperties())
    let newTree = box(DefaultProperties(), [newChild1, child2, child3])

    node?.update(with: newTree)
    let newTextNode = node?.children?[0] as? NativeNode<Text>
    XCTAssertNotNil(newTextNode)
    XCTAssertEqual(3, node?.children?.count)
  }

  func testMoveChild() {
    let child1 = box(DefaultProperties(["width": Float(1), "key": "1"]))
    let child2 = box(DefaultProperties(["width": Float(2), "key": "2"]))
    let child3 = box(DefaultProperties(["width": Float(3), "key": "3"]))

    let tree = box(DefaultProperties(), [child1, child2, child3])
    let node = tree.build(withOwner: nil, context: nil) as? NativeNode<Box>
    let builtChild1 = node?.children?[0] as? NativeNode<Box>
    let builtChild2 = node?.children?[1] as? NativeNode<Box>
    let builtChild3 = node?.children?[2] as? NativeNode<Box>

    let reorderedTree = box(DefaultProperties(), [child2, child3, child1])
    node?.update(with: reorderedTree)

    XCTAssertEqual(node?.children?[0] as? NativeNode<Box>, builtChild2)
    XCTAssertEqual(node?.children?[1] as? NativeNode<Box>, builtChild3)
    XCTAssertEqual(node?.children?[2] as? NativeNode<Box>, builtChild1)
  }

  func testAddChildren() {
    let child1 = box(DefaultProperties(["width": Float(1), "key": "1"]))
    let child2 = box(DefaultProperties(["width": Float(2), "key": "2"]))
    let child3 = box(DefaultProperties(["width": Float(3), "key": "3"]))

    let tree = box(DefaultProperties(), [child1])
    let node = tree.build(withOwner: nil, context: nil) as? NativeNode<Box>
    let builtChild1 = node?.children?[0] as? NativeNode<Box>

    let smallerTree = box(DefaultProperties(), [child1, child2, child3])

    XCTAssertEqual(1, node?.children?.count)
    node?.update(with: smallerTree)
    XCTAssertEqual(3, node?.children?.count)
    XCTAssertEqual(node?.children?[0] as? NativeNode<Box>, builtChild1)
  }

  func testRemoveChildren() {
    let child1 = box(DefaultProperties(["width": Float(1), "key": "1"]))
    let child2 = box(DefaultProperties(["width": Float(2), "key": "2"]))
    let child3 = box(DefaultProperties(["width": Float(3), "key": "3"]))

    let tree = box(DefaultProperties(), [child1, child2, child3])
    let node = tree.build(withOwner: nil, context: nil) as? NativeNode<Box>
    let smallerTree = box(DefaultProperties(), [child1])

    XCTAssertEqual(3, node?.children?.count)
    node?.update(with: smallerTree)
    XCTAssertEqual(1, node?.children?.count)
  }
}
