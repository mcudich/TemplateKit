//
//  Animator.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/19/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol AnimatorObserver {
  var hashValue: Int { get }
  func didAnimate()
  func equals(_ other: AnimatorObserver) -> Bool
}

struct TickableKey: Hashable {
  let tickable: Tickable

  var hashValue: Int {
    return tickable.hashValue
  }
}

func ==(lhs: TickableKey, rhs: TickableKey) -> Bool {
  return lhs.tickable.equals(rhs.tickable)
}

struct AnimatorObserverValue: Hashable {
  let animatorObserver: AnimatorObserver

  var hashValue: Int {
    
    return animatorObserver.hashValue
  }
}

func ==(lhs: AnimatorObserverValue, rhs: AnimatorObserverValue) -> Bool {
  return lhs.animatorObserver.equals(rhs.animatorObserver)
}

public class Animator {
  public static let shared = Animator()

  private lazy var animatables = [Tickable]()
  private lazy var observers = [TickableKey: AnimatorObserverValue]()

  private lazy var displayLink: CADisplayLink = {
    let displayLink = CADisplayLink(target: self, selector: #selector(Animator.render))
    displayLink.isPaused = true
    displayLink.add(to: RunLoop.main, forMode: .commonModes)
    return displayLink
  }()

  public func addAnimatable(_ animatable: Tickable) {
    animatables.append(animatable)
    updateDisplayLink()
  }

  public func addObserver<T: AnimatorObserver>(_ observer: T, for animatable: Tickable) {
    let key = TickableKey(tickable: animatable)
    observers[key] = AnimatorObserverValue(animatorObserver: observer)
  }

  @objc private func render() {
    var validObservers = Set<AnimatorObserverValue>()
    for animatable in animatables {
      animatable.tick(time: CACurrentMediaTime())
      if let observer = observers[TickableKey(tickable: animatable)] {
        validObservers.insert(observer)
      }
    }

    for observer in validObservers {
      observer.animatorObserver.didAnimate()
    }

    animatables = animatables.reduce([]) { accum, value in
      if value.state == .running {
        return accum + [value]
      } else {
        observers.removeValue(forKey: TickableKey(tickable: value))
      }

      return accum
    }

    updateDisplayLink()
  }

  private func updateDisplayLink() {
    let pause = animatables.count == 0
    displayLink.isPaused = pause
  }
}
