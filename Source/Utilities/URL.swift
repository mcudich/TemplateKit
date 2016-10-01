//
//  URL.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/30/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
  public typealias StringLiteralType = String
  public typealias UnicodeScalarLiteralType = String
  public typealias ExtendedGraphemeClusterLiteralType = String

  public init(stringLiteral value: URL.StringLiteralType) {
      self = URL(string: value)!
  }
  public init(extendedGraphemeClusterLiteral value: URL.ExtendedGraphemeClusterLiteralType) {
      self = URL(string: value)!
  }
  public init(unicodeScalarLiteral value: URL.UnicodeScalarLiteralType) {
      self = URL(string: value)!
  }
}
