//
//  Validation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension Dictionary {
  func float(_ key: Key) -> Float? {
    return safeCast(self[key])
  }

  func safeCast<T: StringRepresentable>(_ value: Any?) -> T? {
    if let value = value as? T {
      return value
    }
    if let value = value as? String {
      return T.fromString(value)
    }
    return nil
  }
}

public protocol ValidationType {
  func validate(_ value: Any?) -> Any?
}

public enum Validation: String, ValidationType {
  case string
  case float
  case integer
  case boolean
  case url
  case color
  case selector
  case any

  public func validate<T>(_ value: Any?) -> T? {
    var validatedValue: Any?

    switch self {
    case .string:
      if value is String {
        validatedValue = value
      }
    case .float:
      if value is CGFloat || value is Float {
        validatedValue = value
      }
      if let stringValue = value as? String {
        validatedValue = stringValue.float
      }
    case .integer:
      if value is Integer {
        validatedValue = value
      }
      if let stringValue = value as? String {
        validatedValue = stringValue.integer
      }
    case .boolean:
      if value is Bool {
        validatedValue = value
      }
      if let stringValue = value as? String {
        validatedValue = stringValue.boolean
      }
    case .url:
      if value is URL {
        validatedValue = value
      }
      if let stringValue = value as? String {
        validatedValue = stringValue.url
      }
    case .color:
      if value is UIColor {
        validatedValue = value
      }
      if let stringValue = value as? String {
        validatedValue = stringValue.color
      }
    case .selector:
      if value is Selector {
        validatedValue = value
      }
      if let stringValue = value as? String {
        validatedValue = Selector(stringValue)
      }
    case .any:
      validatedValue = value
    }

    return validatedValue as? T
  }
}
