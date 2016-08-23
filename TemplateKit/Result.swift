//
//  Result.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/22/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

enum Result<ResultType> {
  case success(ResultType)
  case error(Error)

  var payload: ResultType? {
    if case let .success(result) = self {
      return result
    }
    return nil
  }

  var error: Error? {
    if case let .error(error) = self {
      return error
    }
    return nil
  }
}
