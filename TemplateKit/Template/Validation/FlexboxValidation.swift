//
//  FlexboxValidation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/2/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

extension String {
  var flexDirection: Direction {
    switch self {
    case "row":
      return .row
    case "column":
      return .column
    default:
      fatalError("Unknown direction value")
    }
  }

  var justification: Justification {
    switch self {
    case "flexStart":
      return .flexStart
    case "center":
      return .center
    case "flexEnd":
      return .flexEnd
    case "spaceBetween":
      return .spaceBetween
    case "spaceAround":
      return .spaceAround
    default:
      fatalError("Unknown justification value")
    }
  }

  var selfAlignment: SelfAlignment {
    switch self {
    case "auto":
      return .auto
    case "flexStart":
      return .flexStart
    case "center":
      return .center
    case "flexEnd":
      return .flexEnd
    case "stretch":
      return .stretch
    default:
      fatalError("Unknown selfAlignment value")
    }
  }

  var childAlignment: ChildAlignment {
    switch self {
    case "flexStart":
      return .flexStart
    case "center":
      return .center
    case "flexEnd":
      return .flexEnd
    case "stretch":
      return .stretch
    default:
      fatalError("Unknown childAlignment value")
    }
  }
}

enum FlexboxValidation: String, ValidationType {
  case flexDirection
  case justification
  case selfAlignment
  case childAlignment

  func validate(value: Any?) -> Any? {
    switch self {
    case .flexDirection:
      if value is Direction {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.flexDirection
      }
    case .justification:
      if value is Justification {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.justification
      }
    case .selfAlignment:
      if value is SelfAlignment {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.selfAlignment
      }
    case .childAlignment:
      if value is ChildAlignment {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.childAlignment
      }
    }

    if value != nil {
      fatalError("Unhandled type!")
    }

    return nil
  }
}
