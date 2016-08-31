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

public protocol GestureHandler {
  func addTapHandler(target: Any?, action: Selector?)
}

public protocol View: Renderable, GestureHandler {
  var calculatedFrame: CGRect? { set get }
  var propertyProvider: PropertyProvider? { set get }

  init()
  func render() -> UIView
}

extension View {
  public func sizeToFit(_ size: CGSize) {
    if calculatedFrame == nil {
      calculatedFrame = CGRect.zero
    }
    calculatedFrame?.size = sizeThatFits(size)
  }

  public func addTapHandler(target: Any?, action: Selector?) {}
}

extension View where Self: UIView {
  public func addTapHandler(target: Any?, action: Selector?) {
    let gestureRecognizer = UITapGestureRecognizer(target: target, action: action)
    addGestureRecognizer(gestureRecognizer)
  }
}
