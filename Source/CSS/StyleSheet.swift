//
//  Stylesheet.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import Katana

public enum Match {
  case tag
  case id
  case className
  case attributeExact

  init(_ rawValue: KatanaSelectorMatch) {
    switch rawValue {
    case KatanaSelectorMatchTag:
      self = .tag
    case KatanaSelectorMatchId:
      self = .id
    case KatanaSelectorMatchClass:
      self = .className
    case KatanaSelectorMatchAttributeExact:
      self = .attributeExact
    default:
      fatalError()
    }
  }
}

public enum Relation {
  case subselector
  case descendant
  case child
  case directAdjacent
  case indirectAdjacent

  init(_ rawValue: KatanaSelectorRelation) {
    switch rawValue {
    case KatanaSelectorRelationSubSelector:
      self = .subselector
    case KatanaSelectorRelationDescendant:
      self = .descendant
    case KatanaSelectorRelationChild:
      self = .child
    case KatanaSelectorRelationDirectAdjacent:
      self = .directAdjacent
    case KatanaSelectorRelationIndirectAdjacent:
      self = .indirectAdjacent
    default:
      fatalError()
    }
  }
}

public struct Rule {
  public let selectors: [StyleSelector]
  public let declarations: [StyleDeclaration]

  public init(selectors: [StyleSelector], declarations: [StyleDeclaration]) {
    self.selectors = selectors
    self.declarations = declarations
  }

  public func matches(_ element: StyleElement) -> Bool {
    return selectors.contains { selector in
      return selector.matches(element)
    }
  }

  public func greatestSpecificity(for element: StyleElement) -> Int {
    var specificity = 0
    for selector in selectors {
      if selector.matches(element) {
        var underlyingSelector = selector.selector!
        specificity = max(specificity, Int(katana_calc_specificity_for_selector(&underlyingSelector)))
      }
    }
    return specificity
  }
}

public struct RareData {
  var value: String?
  var attribute: String?
}

public struct StyleSelectorData {
  var match: Match?
  var relation: Relation?
  var selector: KatanaSelector?
  var data: RareData?
  var value: String?
}

public indirect enum StyleSelector {
  case none
  case some(StyleSelectorData, StyleSelector)

  public var match: Match? {
    if case let .some(data, _) = self {
      return data.match
    }
    return nil
  }

  public var related: StyleSelector? {
    if case let .some(_, related) = self {
      return related
    }
    return nil
  }

  public var relation: Relation? {
    if case let .some(data, _) = self {
      return data.relation
    }
    return nil
  }

  public var selector: KatanaSelector? {
    if case let .some(data, _) = self {
      return data.selector
    }
    return nil
  }

  public var data: RareData? {
    if case let .some(data, _) = self {
      return data.data
    }
    return nil
  }

  public var value: String? {
    if case let .some(data, _) = self {
      return data.value
    }
    return nil
  }

  public func matches(_ element: StyleElement) -> Bool {
    if case .none = self {
      return true
    }

    guard let match = match, let value = value else {
      return false
    }

    var matches: Bool
    switch match {
    case .id:
      matches = element.id == value
    case .className:
      matches = element.classNames?.contains(value) ?? false
    case .tag:
      matches = element.tagName == value
    case .attributeExact:
      if let data = data, let attribute = data.attribute, let value = data.value {
        matches = element.has(attribute: attribute, with: value)
      } else {
        matches = false
      }
    }

    if !matches {
      return false
    }

    guard let relation = relation, let related = related else {
      return true
    }

    switch relation {
    case .subselector:
      return related.matches(element)
    case .descendant:
      var parent = element.parentElement
      while let currentParent = parent {
        if related.matches(currentParent) {
          return true
        }
        parent = currentParent.parentElement
      }
      return false
    case .child:
      guard let parent = element.parentElement else {
        return false
      }
      return related.matches(parent)
    case .directAdjacent:
      guard let directAdjacent = element.parentElement?.directAdjacent(of: element) else {
        return false
      }
      return related.matches(directAdjacent)
    case .indirectAdjacent:
      guard let indirectAdjacents = element.parentElement?.indirectAdjacents(of: element) else {
        return false
      }
      return indirectAdjacents.contains { indirectAdjacent in
        return related.matches(indirectAdjacent)
      }
    }
  }
}

public struct StyleDeclaration {
  public let name: String
  public let values: [String]
  public let important: Bool
}

public struct StyleSheet {
  public var rules = [Rule]()

  public init(rules: [Rule]) {
    self.rules = rules
  }

  public init?(string: String) {
    guard let data = string.data(using: String.Encoding.utf8) else {
      return nil
    }

    data.withUnsafeBytes { (bytes: UnsafePointer<Int8>) -> Void in
      guard let parsed = katana_parse(bytes, data.count, KatanaParserModeStylesheet) else {
        return
      }
      let stylesheet = parsed.pointee.stylesheet.pointee
      let rules: [KatanaStyleRule] = fromKatanaArray(array: stylesheet.rules)
      self.rules = rules.map { rule in
        let parsedSelectors: [KatanaSelector] = fromKatanaArray(array: rule.selectors.pointee)
        let selectors = parsedSelectors.map { selector in
          return makeSelector(selector)
        }
        let parsedDeclarations: [KatanaDeclaration] = fromKatanaArray(array: rule.declarations.pointee)
        let declarations = parsedDeclarations.map { declaration in
          return makeDeclaration(declaration)
        }
        return Rule(selectors: selectors, declarations: declarations)
      }
    }
  }

  public func rulesForElement(_ element: StyleElement) -> [Rule] {
    return rules.filter { rule in
      return rule.matches(element)
    }
  }

  public func stylesForElement(_ element: StyleElement) -> [String: StyleDeclaration] {
    var declarations = [String: (Rule, StyleDeclaration)]()
    for rule in rulesForElement(element) {
      for declaration in rule.declarations {
        if let (existingRule, _) = declarations[declaration.name] {
          let existingSpecificity = existingRule.greatestSpecificity(for: element)
          let newSpecificity = rule.greatestSpecificity(for: element)
          if newSpecificity > existingSpecificity {
            declarations[declaration.name] = (rule, declaration)
          }
        } else {
          declarations[declaration.name] = (rule, declaration)
        }
      }
    }

    var declarationMap = [String: StyleDeclaration]()
    for (key, (_, declaration)) in declarations {
      declarationMap[key] = declaration
    }
    return declarationMap
  }

  private func makeSelector(_ selector: KatanaSelector) -> StyleSelector {
    let parent = selector.tagHistory == nil ? .none : makeSelector(selector.tagHistory.pointee)

    var value = ""
    if selector.tag != nil {
      value = String(cString: selector.tag.pointee.local)
    } else {
      value = String(cString: selector.data.pointee.value)
    }

    var rareData = RareData()
    if selector.data.pointee.value != nil {
      rareData.value = String(cString: selector.data.pointee.value)
    }
    if selector.data.pointee.attribute != nil {
      rareData.attribute = String(cString: selector.data.pointee.attribute.pointee.local)
    }

    let data = StyleSelectorData(match: Match(selector.match), relation: Relation(selector.relation), selector: selector, data: rareData, value: value)

    return .some(data, parent)
  }

  private func makeDeclaration(_ declaration: KatanaDeclaration) -> StyleDeclaration {
    return StyleDeclaration(name: String(cString: declaration.property), values: makeValues(declaration.values.pointee), important: declaration.important)
  }

  private func makeValues(_ values: KatanaArray) -> [String] {
    let values: [KatanaValue] = fromKatanaArray(array: values)
    return values.map { value in
      if value.isInt {
        return String(cString: value.raw)
      } else if value.value.fValue >= Double.leastNormalMagnitude {
        return "\(value.value.fValue)"
      } else {
        return String(cString: value.value.string)
      }

    }
  }

  private func fromKatanaArray<T>(array: KatanaArray) -> [T] {
    var data = array.data
    var results = [T]()
    for _ in 0..<array.length {
      guard let rule = data?.pointee?.assumingMemoryBound(to: T.self).pointee else {
        continue
      }
      data = data?.advanced(by: 1)
      results.append(rule)
    }
    return results
  }
}
