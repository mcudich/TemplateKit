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
  func applyCommonProperties() {
    applyBackgroundColor()
    applyBorder()
    applyCornerRadius()
    applyTapHandler()
  }

  private func applyBackgroundColor() {
    backgroundColor = properties.style.backgroundColor
  }

  private func applyBorder() {
    guard let borderColor = properties.style.borderColor else {
      return
    }
    layer.borderColor = borderColor.cgColor
    layer.borderWidth = (properties.style.borderWidth ?? 1) / UIScreen.main.scale
  }

  private func applyCornerRadius() {
    guard let cornerRadius = properties.style.cornerRadius else {
      return
    }
    self.layer.cornerRadius = cornerRadius
  }

  private func applyTapHandler() {
    if let onTap = properties.gestures.onTap {
      let recognizer = UITapGestureRecognizer(target: eventTarget, action: onTap)
      addGestureRecognizer(recognizer)
    } else if let onDoubleTap = properties.gestures.onDoubleTap {
      let recognizer = UITapGestureRecognizer(target: eventTarget, action: onDoubleTap)
      recognizer.numberOfTapsRequired = 2
      addGestureRecognizer(recognizer)
    }
  }

  public func touchesBegan() {
    if let onPress = properties.gestures.onPress {
      let _ = eventTarget?.perform(onPress)
    }
  }
}
