//
//  FlexboxValidation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/2/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

extension String {
  var flexDirection: CSSFlexDirection {
    switch self {
    case "row":
      return CSSFlexDirectionRow
    case "column":
      return CSSFlexDirectionColumn
    default:
      fatalError("Unknown direction value")
    }
  }

  var justification: CSSJustify {
    switch self {
    case "flexStart":
      return CSSJustifyFlexStart
    case "center":
      return CSSJustifyCenter
    case "flexEnd":
      return CSSJustifyFlexEnd
    case "spaceBetween":
      return CSSJustifySpaceBetween
    case "spaceAround":
      return CSSJustifySpaceAround
    default:
      fatalError("Unknown justification value")
    }
  }

  var selfAlignment: CSSAlign {
    switch self {
    case "auto":
      return CSSAlignAuto
    case "flexStart":
      return CSSAlignFlexStart
    case "center":
      return CSSAlignCenter
    case "flexEnd":
      return CSSAlignFlexEnd
    case "stretch":
      return CSSAlignStretch
    default:
      fatalError("Unknown selfAlignment value")
    }
  }

  var childAlignment: CSSAlign {
    switch self {
    case "flexStart":
      return CSSAlignFlexStart
    case "center":
      return CSSAlignCenter
    case "flexEnd":
      return CSSAlignFlexEnd
    case "stretch":
      return CSSAlignStretch
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

  func validate(_ value: Any?) -> Any? {
    switch self {
    case .flexDirection:
      if value is CSSFlexDirection {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.flexDirection
      }
    case .justification:
      if value is CSSJustify {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.justification
      }
    case .selfAlignment:
      if value is CSSAlign {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.selfAlignment
      }
    case .childAlignment:
      if value is CSSAlign {
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
