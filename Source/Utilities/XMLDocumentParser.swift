//
//  XMLDocument.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/25/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class XMLElement: Equatable {
  var name: String
  var value: String?
  var parent: XMLElement?
  lazy var children = [XMLElement]()
  lazy var attributes = [String: String]()

  init(name: String, attributes: [String: String]) {
    self.name = name
    self.attributes = attributes
  }

  func addChild(name: String, attributes: [String: String]) -> XMLElement {
    let element = XMLElement(name: name, attributes: attributes)
    element.parent = self
    children.append(element)
    return element
  }
}

func ==(lhs: XMLElement, rhs: XMLElement) -> Bool {
  return lhs.name == rhs.name && lhs.attributes == rhs.attributes && lhs.children == rhs.children
}

enum XMLError: Error {
  case parserError(String)
}

class XMLDocument: NSObject, XMLParserDelegate {
  let data: Data
  private(set) var root: XMLElement?

  private var currentParent: XMLElement?
  private var currentElement: XMLElement?
  private var currentValue = ""
  private var parseError: Error?

  init(data: Data) throws {
    self.data = data

    super.init()

    try parse()
  }

  private func parse() throws {
    let parser = XMLParser(data: data)
    parser.delegate = self

    guard parser.parse() else {
      guard let error = parseError else {
        throw XMLError.parserError("Failure parsing: \(parseError?.localizedDescription)")
      }
      throw error
    }
  }

  @objc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict) ?? XMLElement(name: elementName, attributes: attributeDict)
    if root == nil {
      root = currentElement!
    }
    currentParent = currentElement
  }

  @objc func parser(_ parser: XMLParser, foundCharacters string: String) {
    currentValue += string
    let newValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
    currentElement?.value = newValue.isEmpty ? nil : newValue
  }

  @objc func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    currentParent = currentParent?.parent
    currentElement = nil
    currentValue = ""

  }

  @objc func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    self.parseError = parseError
  }
}
