//
//  StyleElement.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol StyleElement {
  var id: String? { get }
  var classNames: [String]? { get }
  var tagName: String? { get }
  var parentElement: StyleElement? { get }
  var childElements: [StyleElement]? { get }

  var isFocused: Bool { get }
  var isEnabled: Bool { get }
  var isActive: Bool { get }

  func has(attribute: String, with value: String) -> Bool
  func equals(_ other: StyleElement) -> Bool
}

extension StyleElement {
  public func directAdjacent(of element: StyleElement) -> StyleElement? {
    guard let childElements = childElements, let index = index(of: element), index > 0 else {
      return nil
    }

    return childElements[index - 1]
  }

  public func indirectAdjacents(of element: StyleElement) -> [StyleElement] {
    guard let childElements = childElements, let index = index(of: element), index > 0 else {
      return []
    }

    return Array(childElements[0..<index])
  }

  public func subsequentAdjacents(of element: StyleElement) -> [StyleElement] {
    guard let childElements = childElements, let index = index(of: element), index < childElements.count - 1 else {
      return []
    }

    return Array(childElements[index + 1..<childElements.count])
  }

  private func index(of child: StyleElement) -> Int? {
    guard let childElements = childElements else {
      return nil
    }

    return childElements.index { element in
      return child.equals(element)
    }
  }
}
