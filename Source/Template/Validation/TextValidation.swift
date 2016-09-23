//
//  TextValidation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/2/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension String {
  var textAlignment: NSTextAlignment? {
    switch self {
    case "left":
      return .left
    case "center":
      return .center
    case "right":
      return .right
    case "justified":
      return .justified
    case "natural":
      return .natural
    default:
      fatalError("Unhandled value")
    }
  }

  var lineBreakMode: NSLineBreakMode? {
    switch self {
    case "byWordWrapping":
      return .byWordWrapping
    case "byCharWrapping":
      return .byCharWrapping
    case "byClipping":
      return .byClipping
    case "byTruncatingHead":
      return .byTruncatingHead
    case "byTruncatingTail":
      return .byTruncatingTail
    case "byTruncatingMiddle":
      return .byTruncatingMiddle
    default:
      fatalError("Unhandled value")
    }
  }
}

enum TextValidation: String, ValidationType {
  case textAlignment
  case lineBreakMode

  func validate(_ value: Any?) -> Any? {
    switch self {
    case .textAlignment:
      if value is NSTextAlignment {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.textAlignment
      }
    case .lineBreakMode:
      if value is NSLineBreakMode {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.lineBreakMode
      }
    }

    if value != nil {
      fatalError("Unhandled type!")
    }

    return nil
  }
}
