//
//  Component+Animation.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/23/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension Component: AnimatorObserver {
  public var hashValue: Int {
    return ObjectIdentifier(self as AnyObject).hashValue
  }

  public func didAnimate() {
    let root = self.root
    getContext().updateQueue.async {
      self.update(with: self.element, force: true)
      let layout = root.computeLayout()
      DispatchQueue.main.async {
        _ = self.build()
        layout.apply(to: root.view)
      }
    }
  }

  public func animate<T>(_ animatable: Animatable<T>, to value: T) {
    animatable.set(value)
    Animator.shared.addAnimatable(animatable)
    Animator.shared.addObserver(self, for: animatable)
  }

  public func equals(_ other: AnimatorObserver) -> Bool {
    guard let other = other as? Component<StateType, PropertiesType, ViewType> else {
      return false
    }
    return self == other
  }
}
