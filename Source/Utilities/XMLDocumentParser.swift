//
//  XMLDocument.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/25/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class XMLElement {
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

enum XMLError: Error {
  case parserError(String)
}

class XMLDocumentParser: NSObject, XMLParserDelegate {
  let data: Data

  var root: XMLElement?
  var currentParent: XMLElement?
  var currentElement: XMLElement?
  var currentValue = ""

  var parseError: Error?

  init(data: Data) {
    self.data = data

    super.init()
  }

  func parse() throws -> XMLElement {
    let parser = XMLParser(data: data)
    parser.delegate = self

    guard parser.parse(), let root = root else {
      guard let error = parseError else {
        throw XMLError.parserError("Failure parsing: \(parseError?.localizedDescription)")
      }
      throw error
    }

    return root
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
