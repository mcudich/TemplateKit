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
      return subviews
    }
    set {
      var viewsToRemove = Set(subviews)

      for (index, child) in newValue.enumerated() {
        let childView = child as! UIView
        insertSubview(childView, at: index)
        viewsToRemove.remove(childView)
      }

      viewsToRemove.forEach { $0.removeFromSuperview() }
    }
  }

  public var parent: View? {
    return superview as? View
  }

  public func add(_ view: View) {
    addSubview(view as! UIView)
  }

  public func replace(_ view: View, with newView: View) {
    guard let currentIndex = subviews.index(of: view as! UIView) else {
      return
    }
    (view as! UIView).removeFromSuperview()
    insertSubview(newView as! UIView, at: currentIndex)
  }
}

extension NativeView where Self: UIView {
  func applyCoreProperties() {
    applyBackgroundColor()
    applyBorder()
    applyCornerRadius()
    applyOpacity()
    applyTapHandler()
  }

  private func applyBackgroundColor() {
    backgroundColor = properties.core.style.backgroundColor
  }

  private func applyBorder() {
    layer.borderColor = properties.core.style.borderColor?.cgColor

    if layer.borderColor != nil {
      layer.borderWidth = (properties.core.style.borderWidth ?? 1) / UIScreen.main.scale
    }
  }

  private func applyCornerRadius() {
    layer.cornerRadius = properties.core.style.cornerRadius ?? 0
  }

  private func applyOpacity() {
    alpha = properties.core.style.opacity ?? 1
    isOpaque = alpha < 1
  }

  private func applyTapHandler() {
    for recognizer in eventRecognizers {
      if let recognizer = recognizer as? UIGestureRecognizer {
        removeGestureRecognizer(recognizer)
      }
    }

    var recognizer: UITapGestureRecognizer?
    if let onTap = properties.core.gestures.onTap {
      recognizer = UITapGestureRecognizer(target: eventTarget, action: onTap)
    } else if let onDoubleTap = properties.core.gestures.onDoubleTap {
      recognizer = UITapGestureRecognizer(target: eventTarget, action: onDoubleTap)
      recognizer?.numberOfTapsRequired = 2
    }
    if let recognizer = recognizer {
      addGestureRecognizer(recognizer)
      eventRecognizers.append(recognizer)
    }
  }

  public func touchesBegan() {
    if let onPress = properties.core.gestures.onPress {
      let _ = eventTarget?.perform(onPress)
    }
  }
}
