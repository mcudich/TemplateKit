//
//  UIView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension UIView: View {
  public var children: [View] {
    get {
      return subviews.map { $0 as View }
    }
    set {
      var pendingViews = Set(subviews)

      for (index, child) in (newValue ?? []).enumerated() {
        let childView = child as! UIView
        insertSubview(childView, at: index)
        pendingViews.remove(childView)
      }

      pendingViews.forEach { $0.removeFromSuperview() }
    }
  }

  public var parent: View? {
    return superview as? View
  }

  public func add(_ view: View) {
    addSubview(view as! UIView)
  }

  public func replace(_ view: View, with newView: View) {
    let currentIndex = subviews.index(of: view as! UIView)!
    (view as! UIView).removeFromSuperview()
    insertSubview(newView as! UIView, at: currentIndex)
  }
}

extension NativeView where Self: UIView {
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
