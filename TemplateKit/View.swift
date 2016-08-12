//
//  View.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Renderable: class {
  func render() -> UIView
  func sizeThatFits(_ size: CGSize) -> CGSize
  func sizeToFit(_ size: CGSize)
}

public protocol PropertyProvider: class {
  func get<T>(_ key: String) -> T?
}

public protocol View: Renderable {
  static var propertyTypes: [String: Validator] { get }

  var calculatedFrame: CGRect? { set get }
  var propertyProvider: PropertyProvider? { set get }

  init()
  func render() -> UIView
}

let defaultPropertyTypes = [
    "x": Validation.float(),
    "y": Validation.float(),
    "width": Validation.float(),
    "height": Validation.float(),
]

extension View {
  public func sizeToFit(_ size: CGSize) {
    calculatedFrame?.size = sizeThatFits(size)
  }
}
