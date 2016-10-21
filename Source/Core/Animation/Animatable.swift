//
//  Animatable.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/18/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public enum AnimationState {
  case pending
  case running
  case done
}

public protocol Tickable {
  var hashValue: Int { get }
  var state: AnimationState { get }

  func tick(time: TimeInterval)
  func equals(_ other: Tickable) -> Bool
}

public class Animatable<T: Equatable & Interpolatable>: Tickable, Model, Equatable {
  public var hashValue: Int {
    return ObjectIdentifier(self as AnyObject).hashValue
  }

  public private(set) var value: T?
  public var duration: TimeInterval = 0
  public var delay: TimeInterval = 0
  public var easingFunction = EasingFunction.linear

  public var state: AnimationState {
    if toValue != nil && beginTime == nil {
      return .pending
    } else if beginTime != nil {
      return .running
    }
    return .done
  }

  private var fromValue: T?
  private var toValue: T?
  private var beginTime: TimeInterval?

  public init(_ value: T?, duration: TimeInterval = 0, delay: TimeInterval = 0, easingFunction: EasingFunction = .linear) {
    self.value = value
    self.duration = duration
    self.delay = delay
    self.easingFunction = easingFunction
  }

  public func set(_ value: T?) {
    if value != self.value && duration > 0 {
      fromValue = self.value
      toValue = value
      return
    }

    self.value = value
  }

  public func tick(time: TimeInterval) {
    if beginTime == nil {
      beginTime = time
    }
    guard let beginTime = beginTime, let fromValue = fromValue, let toValue = toValue, time >= beginTime + delay else {
      return
    }

    let effectiveBeginTime = beginTime + delay
    if time - effectiveBeginTime > duration {
      reset()
      return
    }

    value = T.interpolate(time - effectiveBeginTime, fromValue, toValue, duration, easingFunction)
  }

  public func reset() {
    beginTime = nil
    toValue = nil
    fromValue = nil
  }

  public func equals(_ other: Tickable) -> Bool {
    guard let other = other as? Animatable<T> else {
      return false
    }
    return self == other
  }
}

public func ==<T: Equatable>(lhs: Animatable<T>, rhs: Animatable<T>) -> Bool {
  return lhs.value == rhs.value
}
