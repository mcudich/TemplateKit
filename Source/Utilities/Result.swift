//
//  Result.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/22/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public enum Result<ResultType> {
  case success(ResultType)
  case failure(Error)

  var payload: ResultType? {
    if case let .success(result) = self {
      return result
    }
    return nil
  }

  var error: Error? {
    if case let .failure(error) = self {
      return error
    }
    return nil
  }
}
