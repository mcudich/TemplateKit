//
//  StylesheetTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
import TemplateKit

class TestElement: StyleElement {
  var id: String?
  var classNames: [String]?
  var tagName: String?
  var parentElement: StyleElement?
  var childElements: [StyleElement]?

  init(id: String? = nil, classNames: [String]? = nil, tagName: String? = nil, parent: StyleElement? = nil, children: [StyleElement]? = nil) {
    self.id = id
    self.classNames = classNames
    self.tagName = tagName
    self.parentElement = parent
    self.childElements = children
  }
}

class StylesheetTests: XCTestCase {
  func testParsesSelector() {
    let sheet = ".test .other, #orThis { height: red; width: 100 }"
    let parsed = StyleSheet(string: sheet)!
    XCTAssertNotNil(parsed)
    XCTAssertEqual(1, parsed.rules.count)

    let rule = parsed.rules[0]
    XCTAssertEqual(2, rule.selectors.count)

    let firstSelector = rule.selectors[0]
    XCTAssertEqual(Match.className, firstSelector.match)
    XCTAssertEqual("other", firstSelector.value)
    XCTAssertEqual(Relation.descendant, firstSelector.relation)

    let relatedFirstSelector = firstSelector.related!
    XCTAssertEqual(Match.className, relatedFirstSelector.match)
    XCTAssertEqual("test", relatedFirstSelector.value)
    XCTAssertEqual(Relation.subselector, relatedFirstSelector.relation)
    XCTAssertNil(relatedFirstSelector.related?.value)

    let secondSelector = rule.selectors[1]
    XCTAssertEqual(Match.id, secondSelector.match)
    XCTAssertEqual("orThis", secondSelector.value)
    XCTAssertEqual(Relation.subselector, secondSelector.relation)
    XCTAssertNil(secondSelector.related?.value)

    XCTAssertEqual(2, rule.declarations.count)
    XCTAssertEqual("height", rule.declarations[0].name)
    XCTAssertEqual("red", rule.declarations[0].values[0])
    XCTAssertEqual("width", rule.declarations[1].name)
    XCTAssertEqual("100", rule.declarations[1].values[0])
  }

  func testMatchesTag() {
    let sheet = "box { height: 100 } #blah { flex: 1}"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(tagName: "box")
    let matchingRules = parsed.rulesForElement(element)
    XCTAssertEqual(1, matchingRules.count)
    XCTAssertEqual(matchingRules[0].declarations[0].name, "height")

    let counterElement = TestElement(tagName: "square")
    XCTAssertEqual(0, parsed.rulesForElement(counterElement).count)
  }

  func testMatchesClassNames() {
    let sheet = ".other, #orThis { height: red; width: 100 } #someOther { flex: 1 }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(classNames: ["other"])
    let matchingRules = parsed.rulesForElement(element)
    XCTAssertEqual(1, matchingRules.count)
    XCTAssertEqual(matchingRules[0].declarations[0].name, "height")
  }

  func testMatchesId() {
    let sheet = ".test .other, #orThis { height: red; width: 100 } #someOther { flex: 1 }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(id: "orThis")
    let matchingRules = parsed.rulesForElement(element)
    XCTAssertEqual(1, matchingRules.count)
    XCTAssertEqual(matchingRules[0].declarations[0].name, "height")
  }

  func testMatchesSubselector() {
    let sheet = ".some.test { height: 100 } #blah { flex: 1}"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(classNames: ["some", "test"])
    let matchingRules = parsed.rulesForElement(element)
    XCTAssertEqual(1, matchingRules.count)
    XCTAssertEqual(matchingRules[0].declarations[0].name, "height")
  }

  func testMatchesDescendant() {
    let sheet = ".test .other, #orThis { height: red; width: 100 } #someOther { flex: 1 }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(classNames: ["other"])
    let otherMatchingRules = parsed.rulesForElement(element)
    XCTAssertEqual(0, otherMatchingRules.count)

    let root = TestElement(classNames: ["test"])
    let shim = TestElement()
    element.parentElement = shim
    shim.parentElement = root
    XCTAssertEqual(1, parsed.rulesForElement(element).count)
  }

  func testMatchesChild() {
    let sheet = ".test > .other, #orThis { height: red; width: 100 } #someOther { flex: 1 }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(classNames: ["other"])
    XCTAssertEqual(0, parsed.rulesForElement(element).count)

    let root = TestElement(classNames: ["test"])
    element.parentElement = root
    XCTAssertEqual(1, parsed.rulesForElement(element).count)

    let shim = TestElement()
    element.parentElement = shim
    shim.parentElement = root
    XCTAssertEqual(0, parsed.rulesForElement(element).count)
  }

  func testArbitrarilyComplexSelectors() {
    let sheet = ".blah > box.someClass.foo #test { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let testParentParentParent = TestElement(classNames: ["blah"])
    let testParentParent = TestElement(classNames: ["someClass", "foo"], tagName: "box", parent: testParentParentParent)
    let testParent = TestElement(parent: testParentParent)
    let test = TestElement(id: "test", parent: testParent)
    let counter = TestElement(id: "notTest", parent: testParent)

    XCTAssertEqual(1, parsed.rulesForElement(test).count)
    XCTAssertEqual(0, parsed.rulesForElement(counter).count)
  }

  func testSimpleStylesForElement() {
    let sheet = "box { height: 100; width: 200; background-color: green }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(tagName: "box")
    let styles = parsed.stylesForElement(element)
    XCTAssertEqual(3, styles.count)
    XCTAssertEqual("100", styles["height"]?.values[0])
    XCTAssertEqual("200", styles["width"]?.values[0])
    XCTAssertEqual("green", styles["background-color"]?.values[0])
  }

  func testMergedStylesForElement() {
    let sheet = "box { height: 100; width: 200; background-color: green } .focused { border: red }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(classNames: ["focused"], tagName: "box")
    let styles = parsed.stylesForElement(element)
    XCTAssertEqual(4, styles.count)
    XCTAssertEqual("100", styles["height"]?.values[0])
    XCTAssertEqual("200", styles["width"]?.values[0])
    XCTAssertEqual("green", styles["background-color"]?.values[0])
    XCTAssertEqual("red", styles["border"]?.values[0])
  }

  func testSpecificityConstrainedStylesForElement() {
    let sheet = "box { height: 100; width: 200; background-color: green } .focused { height: 300 }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(classNames: ["focused"], tagName: "box")
    let styles = parsed.stylesForElement(element)
    XCTAssertEqual(3, styles.count)
    XCTAssertEqual("300", styles["height"]?.values[0])
    XCTAssertEqual("200", styles["width"]?.values[0])
    XCTAssertEqual("green", styles["background-color"]?.values[0])
  }
}
