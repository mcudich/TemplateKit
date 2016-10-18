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
        if (subviews.count > index && childView !== subviews[index]) || index >= subviews.count {
          insertSubview(childView, at: index)
        }
        viewsToRemove.remove(childView)
      }

      viewsToRemove.forEach { viewToRemove in
        viewToRemove.removeFromSuperview()
      }
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
  }

  private func applyTapHandler() {
    let singleTap = updateTapGestureRecognizer(recognizer: &eventRecognizers.onTap, selector: properties.core.gestures.onTap, numberOfTaps: 1)
    if let doubleTap = updateTapGestureRecognizer(recognizer: &eventRecognizers.onDoubleTap, selector: properties.core.gestures.onDoubleTap, numberOfTaps: 2) {
      singleTap?.require(toFail: doubleTap)
    }
  }

  private func updateTapGestureRecognizer(recognizer: inout EventRecognizers.Recognizer?, selector: Selector?, numberOfTaps: Int) -> UIGestureRecognizer? {
    if let existingRecognizer = recognizer, let selector = selector, selector != existingRecognizer.0 {
      existingRecognizer.1.removeTarget(eventTarget, action: existingRecognizer.0)
      existingRecognizer.1.addTarget(eventTarget, action: selector)
      recognizer = (selector, existingRecognizer.1)
    } else if let selector = selector {
      let newRecognizer = UITapGestureRecognizer(target: eventTarget, action: selector)
      newRecognizer.numberOfTapsRequired = numberOfTaps
      addGestureRecognizer(newRecognizer)
      recognizer = (selector, newRecognizer)
      return newRecognizer
    } else if let existingRecognizer = recognizer {
      removeGestureRecognizer(existingRecognizer.1)
      recognizer = nil
    }
    return nil
  }

  public func touchesBegan() {
    if let onPress = properties.core.gestures.onPress {
      _ = eventTarget?.perform(onPress)
    }
  }
}
