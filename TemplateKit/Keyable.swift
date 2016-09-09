//
//  Keyable.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Keyable {
  var key: String? { get }
}

public extension Keyable where Self: PropertyHolder {
  public var key: String? {
    return get("key")
  }
}
