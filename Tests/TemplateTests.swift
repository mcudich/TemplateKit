//
//  TemplateTests.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import XCTest
@testable import TemplateKit

struct FakeModel: Model {}

class TemplateTests: XCTestCase {
  func testParseTemplate() {
    let template = Bundle(for: TemplateTests.self).url(forResource: "SimpleTemplate", withExtension: "xml")!
    let parsed = try! Template(xml: Data(contentsOf: template))
    let element = try! parsed.makeElement(with: FakeModel()) as! ElementData<BaseProperties>
    XCTAssertEqual(UIColor.red, element.properties.style.backgroundColor)
  }
}
