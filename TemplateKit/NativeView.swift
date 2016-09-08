//
//  NativeView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

public protocol Layoutable {
  func applyLayout(layout: SwiftBox.Layout)
}

extension UIView: Layoutable {
  public func applyLayout(layout: SwiftBox.Layout) {
    Layout.apply(layout, to: self)
  }
}

public protocol View: Layoutable {
  var frame: CGRect { get set }
}

extension UIView: View {}

public protocol NativeView: View, PropertyHolder {
  var eventTarget: AnyObject? { get set }
  var children: [View]? { get set }

  init()
}

extension NativeView where Self: UIView {
  public var children: [View]? {
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
