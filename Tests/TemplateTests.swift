//
//  TemplateTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/26/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
import TemplateKit
import CSSParser

class TemplateTests: XCTestCase {
  struct FakeModel: Model {}

  func testBuildTemplate() {
    let element = box(DefaultProperties(), [])
    let template = Template(element)
    let built = template.build(with: FakeModel())
    XCTAssert(element.equals(built))
  }

  func testApplyStylesheet() {
    let grandchild = text(TextProperties())
    let child = box(DefaultProperties(["classNames": "child"]), [grandchild])
    let parent = box(DefaultProperties(["id": "parent"]), [child])

    let stylesheet = StyleSheet(string: "#parent { fontSize: 20 } .child { width: 50 }", inheritedProperties: ["fontSize"])!
    let template = Template(parent, stylesheet)
    let built = template.build(with: FakeModel()) as! ElementData<DefaultProperties>
    let builtChild = built.children?.first as! ElementData<DefaultProperties>
    let builtGrandchild = child.children?.first as! ElementData<TextProperties>

    XCTAssertEqual(20, built.properties.textStyle.fontSize)
    XCTAssertEqual(20, builtChild.properties.textStyle.fontSize)
    XCTAssertEqual(20, builtGrandchild.properties.textStyle.fontSize)

    XCTAssertEqual(50, builtChild.properties.core.layout.width)
  }
}
