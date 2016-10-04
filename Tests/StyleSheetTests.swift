//
//  StylesheetTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
import TemplateKit

class TestElement: StyleElement, Equatable {
  var id: String?
  var classNames: [String]?
  var tagName: String?
  var parentElement: StyleElement?
  var childElements: [StyleElement]?
  var attributes: [String: String]?

  var isEnabled: Bool
  var isFocused: Bool
  var isSelected: Bool
  var isActive: Bool

  init(id: String? = nil, classNames: [String]? = nil, tagName: String? = nil, parent: StyleElement? = nil, children: [StyleElement]? = nil, attributes: [String: String]? = nil) {
    self.id = id
    self.classNames = classNames
    self.tagName = tagName
    self.parentElement = parent
    self.childElements = children
    self.attributes = attributes
    isEnabled = true
    isFocused = false
    isSelected = false
    isActive = false
  }

  func has(attribute: String, with value: String) -> Bool {
    return attributes?[attribute] == value
  }

  func directAdjacent(of element: StyleElement) -> StyleElement? {
    let index = childElements?.index { child in
      return (child as! TestElement) == (element as! TestElement)
    }
    return childElements![index! - 1]
  }

  func indirectAdjacents(of element: StyleElement) -> [StyleElement] {
    let index = childElements?.index { child in
      return (child as! TestElement) == (element as! TestElement)
    }
    return Array(childElements![0..<index!])
  }

  func subsequentAdjacents(of element: StyleElement) -> [StyleElement] {
    let index = childElements?.index { child in
      return (child as! TestElement) == (element as! TestElement)
    }
    return Array(childElements![index! + 1..<childElements!.count])
  }
}

func ==(lhs: TestElement, rhs: TestElement) -> Bool {
  return lhs === rhs
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
    XCTAssertEqual("red", rule.declarations[0].value)
    XCTAssertEqual("width", rule.declarations[1].name)
    XCTAssertEqual("100", rule.declarations[1].value)
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

  func testMatchesDirectAdjacent() {
    let sheet = ".foo + .bar { height: 100 }"
    let parsed = StyleSheet(string: sheet)!
    let parent = TestElement()
    let childOne = TestElement(classNames: ["foo"], parent: parent)
    let childTwo = TestElement(classNames: ["bar"], parent: parent)
    let childThree = TestElement(classNames: ["bar"], parent: parent)
    parent.childElements = [childOne, childTwo, childThree]

    XCTAssertEqual(1, parsed.rulesForElement(childTwo).count)
    XCTAssertEqual(0, parsed.rulesForElement(childThree).count)
  }

  func testMatchesIndirectDirectAdjacent() {
    let sheet = ".foo ~ .bar { height: 100 }"
    let parsed = StyleSheet(string: sheet)!
    let parent = TestElement()
    let childOne = TestElement(classNames: ["foo"], parent: parent)
    let childTwo = TestElement(classNames: ["bar"], parent: parent)
    let childThree = TestElement(classNames: ["bar"], parent: parent)
    parent.childElements = [childOne, childTwo, childThree]

    XCTAssertEqual(1, parsed.rulesForElement(childTwo).count)
    XCTAssertEqual(1, parsed.rulesForElement(childThree).count)
  }

  func testMatchesAttribute() {
    let sheet = "button { height: 100} button[selected=true] { height: 200 }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(tagName: "button", attributes: ["selected": "false"])
    XCTAssertEqual(1, parsed.rulesForElement(element).count)
    element.attributes?["selected"] = "true"
    XCTAssertEqual(2, parsed.rulesForElement(element).count)
  }

  func testMatchesFirstChild() {
    let sheet = "button:first-child { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement()
    let button1 = TestElement(tagName: "button", parent: parent)
    let button2 = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button1, button2]

    XCTAssertEqual(1, parsed.rulesForElement(button1).count)
    XCTAssertEqual(0, parsed.rulesForElement(button2).count)
  }

  func testMatchesFirstOfType() {
    let sheet = "#parent :first-of-type { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement(id: "parent")
    let button = TestElement(tagName: "button", parent: parent)
    let box = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button, box]

    XCTAssertEqual(1, parsed.rulesForElement(button).count)
    XCTAssertEqual(0, parsed.rulesForElement(box).count)
  }

  func testMatchesLastChild() {
    let sheet = "button:last-child { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement()
    let button1 = TestElement(tagName: "button", parent: parent)
    let button2 = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button1, button2]

    XCTAssertEqual(0, parsed.rulesForElement(button1).count)
    XCTAssertEqual(1, parsed.rulesForElement(button2).count)
  }

  func testMatchesLastOfType() {
    let sheet = "#parent :last-of-type { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement(id: "parent")
    let button = TestElement(tagName: "button", parent: parent)
    let box = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button, box]

    XCTAssertEqual(0, parsed.rulesForElement(button).count)
    XCTAssertEqual(1, parsed.rulesForElement(box).count)
  }

  func testMatchesOnlyChild() {
    let sheet = "#parent :only-child { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement(id: "parent")
    let button = TestElement(tagName: "button", parent: parent)
    let box = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button, box]

    XCTAssertEqual(0, parsed.rulesForElement(button).count)
    XCTAssertEqual(0, parsed.rulesForElement(box).count)

    parent.childElements = [button]
    XCTAssertEqual(1, parsed.rulesForElement(button).count)
  }

  func testMatchesOnlyOfType() {
    let sheet = "button:only-of-type { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement(id: "parent")
    let button1 = TestElement(tagName: "button", parent: parent)
    let button2 = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button1, button2]

    XCTAssertEqual(0, parsed.rulesForElement(button1).count)
    XCTAssertEqual(0, parsed.rulesForElement(button2).count)

    parent.childElements = [button1]
    XCTAssertEqual(1, parsed.rulesForElement(button1).count)
  }

  func testMatchesFocus() {
    let sheet = "button:focus { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement(id: "parent")
    let button1 = TestElement(tagName: "button", parent: parent)
    let button2 = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button1, button2]

    XCTAssertEqual(0, parsed.rulesForElement(button1).count)
    XCTAssertEqual(0, parsed.rulesForElement(button2).count)

    button1.isFocused = true
    XCTAssertEqual(1, parsed.rulesForElement(button1).count)
  }

  func testMatchesActive() {
    let sheet = "button:active { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement(id: "parent")
    let button1 = TestElement(tagName: "button", parent: parent)
    let button2 = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button1, button2]

    XCTAssertEqual(0, parsed.rulesForElement(button1).count)
    XCTAssertEqual(0, parsed.rulesForElement(button2).count)

    button1.isActive = true
    XCTAssertEqual(1, parsed.rulesForElement(button1).count)
  }

  func testMatchesEnabled() {
    let sheet = "button:enabled { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement(id: "parent")
    let button1 = TestElement(tagName: "button", parent: parent)
    let button2 = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button1, button2]

    XCTAssertEqual(1, parsed.rulesForElement(button1).count)
    XCTAssertEqual(1, parsed.rulesForElement(button2).count)

    button1.isEnabled = false
    XCTAssertEqual(0, parsed.rulesForElement(button1).count)
  }

  func testMatchesDisabled() {
    let sheet = "button:disabled { height: 100 }"
    let parsed = StyleSheet(string: sheet)!

    let parent = TestElement(id: "parent")
    let button1 = TestElement(tagName: "button", parent: parent)
    let button2 = TestElement(tagName: "button", parent: parent)
    parent.childElements = [button1, button2]

    XCTAssertEqual(0, parsed.rulesForElement(button1).count)
    XCTAssertEqual(0, parsed.rulesForElement(button2).count)

    button1.isEnabled = false
    XCTAssertEqual(1, parsed.rulesForElement(button1).count)
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
    XCTAssertEqual("100", styles["height"]?.value)
    XCTAssertEqual("200", styles["width"]?.value)
    XCTAssertEqual("green", styles["background-color"]?.value)
  }

  func testMergedStylesForElement() {
    let sheet = "box { height: 100; width: 200; background-color: green } .focused { border: red }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(classNames: ["focused"], tagName: "box")
    let styles = parsed.stylesForElement(element)
    XCTAssertEqual(4, styles.count)
    XCTAssertEqual("100", styles["height"]?.value)
    XCTAssertEqual("200", styles["width"]?.value)
    XCTAssertEqual("green", styles["background-color"]?.value)
    XCTAssertEqual("red", styles["border"]?.value)
  }

  func testSpecificityConstrainedStylesForElement() {
    let sheet = "box { height: 100; width: 200; background-color: green } .focused { height: 300 }"
    let parsed = StyleSheet(string: sheet)!

    let element = TestElement(classNames: ["focused"], tagName: "box")
    let styles = parsed.stylesForElement(element)
    XCTAssertEqual(3, styles.count)
    XCTAssertEqual("300", styles["height"]?.value)
    XCTAssertEqual("200", styles["width"]?.value)
    XCTAssertEqual("green", styles["background-color"]?.value)
  }
}
