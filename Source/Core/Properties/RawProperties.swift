//
//  RawProperties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol RawProperties {
  init(_ properties: [String: Any])
  mutating func merge(_ other: Self)

  mutating func merge<T>(_ value: inout T?, _ newValue: T?)
}

public extension RawProperties {
  public mutating func merge<T>(_ value: inout T?, _ newValue: T?) {
    if let newValue = newValue {
      value = newValue
    }
  }
}
