//
//  UIView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension UIView: Layoutable {
  public func applyLayout(layout: CSSLayout) {
    layout.apply(to: self)
  }
}

extension UIView: View {
  public func addSubview(_ view: View) {
    addSubview(view as! UIView)
  }

  public func replace(_ view: View, with newView: View) {
    let currentIndex = subviews.index(of: view as! UIView)!
    (view as! UIView).removeFromSuperview()
    insertSubview(newView as! UIView, at: currentIndex)
  }
}

extension NativeView where Self: UIView {
  public var children: [View]? {
    set {
    }
    get { return nil }
  }

  func applyCommonProperties(properties: [String: Any]) {
    applyBackgroundColor(properties)
    applyTapHandler(properties)
  }

  private func applyBackgroundColor(_ properties: [String: Any]) {
    guard let backgroundColor: UIColor = get("backgroundColor") else {
      return
    }
    self.backgroundColor = backgroundColor
  }

  private func applyTapHandler(_ properties: [String: Any]) {
    guard let onTap: Selector = get("onTap") else {
      return
    }
    let recognizer = UITapGestureRecognizer(target: eventTarget, action: onTap)
    addGestureRecognizer(recognizer)
  }
}
