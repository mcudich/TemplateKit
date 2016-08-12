//
//  Validation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public typealias Validator = ([String: String], String) -> Any?

enum Validation {
  static func validate(propertyTypes: [String: Validator], properties: [String: String]) -> [String: Any] {
    var sanitized = [String: Any]()
    for (key, rule) in propertyTypes {
      sanitized[key] = rule(properties, key)
    }
    return sanitized
  }

  static func string() -> Validator {
    return { properties, key in
      return properties[key]
    }
  }

  static func float() -> Validator {
    return { properties, key in
      return properties[key]?.float
    }
  }

  static func flexDirection() -> Validator {
    return { properties, key in
      return properties[key]?.flexDirection
    }
  }
}