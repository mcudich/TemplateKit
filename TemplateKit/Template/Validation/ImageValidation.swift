//
//  ImageValidation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/2/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension String {
  var contentMode: UIViewContentMode? {
    switch self {
    case "scaleToFill":
      return .scaleToFill
    case "scaleAspectFit":
      return .scaleAspectFit
    case "scaleAspectFill":
      return .scaleAspectFill
    default:
      fatalError("Unhandled value")
    }
  }
}

enum ImageValidation: String, ValidationType {
  case contentMode

  func validate(value: Any?) -> Any? {
    switch self {
    case .contentMode:
      if value is UIViewContentMode {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.contentMode
      }
    }

    if value != nil {
      fatalError("Unhandled type!")
    }

    return nil
  }
}
