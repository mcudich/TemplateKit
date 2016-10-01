//
//  UIView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension UIView: View {
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
    for recognizer in (gestureRecognizers ?? []) {
      removeGestureRecognizer(recognizer)
    }

    if let onTap = properties.core.gestures.onTap {
      let recognizer = UITapGestureRecognizer(target: eventTarget, action: onTap)
      addGestureRecognizer(recognizer)
    } else if let onDoubleTap = properties.core.gestures.onDoubleTap {
      let recognizer = UITapGestureRecognizer(target: eventTarget, action: onDoubleTap)
      recognizer.numberOfTapsRequired = 2
      addGestureRecognizer(recognizer)
    }
  }

  public func touchesBegan() {
    if let onPress = properties.core.gestures.onPress {
      let _ = eventTarget?.perform(onPress)
    }
  }
}
