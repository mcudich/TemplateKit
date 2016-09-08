//
//  NativeView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol NativeView {
  var eventTarget: AnyObject? { get set }
  var properties: [String: Any] { get set }
  var children: [NativeView]? { get set }

  init()
}

extension NativeView where Self: UIView {
  public var children: [NativeView]? {
    set {
    }
    get { return nil }
  }

  func applyCommonProperties(properties: [String: Any]) {
    applyTapHandler(properties)
  }

  private func applyTapHandler(_ properties: [String: Any]) {
    guard let onTap = properties["onTap"] as? Selector else {
      return
    }
    let recognizer = UITapGestureRecognizer(target: eventTarget, action: onTap)
    addGestureRecognizer(recognizer)
  }
}
