//
//  TemplateTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
@testable import TemplateKit
import CSSParser

struct FakeModel: Model {}

class XMLTemplateServiceTests: XCTestCase {
  func testParseTemplate() {
    let template = Bundle(for: TemplateTests.self).url(forResource: "SimpleTemplate", withExtension: "xml")!
    let xmlTemplate = try! XMLDocument(data: Data(contentsOf: template))
    let styleSheet = StyleSheet(string: xmlTemplate.styleElements.first!.value!)!
    let parsed = Template(xmlTemplate.componentElement!, styleSheet)
    let element = parsed.build(with: FakeModel()) as! ElementData<DefaultProperties>
    XCTAssertEqual(UIColor.red, element.properties.core.style.backgroundColor)
  }
}
