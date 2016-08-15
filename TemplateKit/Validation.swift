//
//  Validation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public typealias Validator = ([String: String], String) -> Any?

public protocol ValidationType {
  func validate(value: String?) -> Any?
}

public enum Validation: ValidationType {
  case string
  case float
  case url
  case flexDirection

  public func validate(value: String?) -> Any? {
    if let value = value, value.hasPrefix("$") {
      return value
    }

    switch self {
    case .string:
      return value
    case .float:
      return value?.float
    case .url:
      return value?.url
    case .flexDirection:
      return value?.flexDirection
    }
  }

  static func validate(propertyTypes: [String: ValidationType], properties: [String: String]) -> [String: Any] {
    var sanitized = [String: Any]()
    for (key, rule) in propertyTypes {
      sanitized[key] = rule.validate(value: properties[key])
    }
    return sanitized
  }
}
