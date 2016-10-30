//
//  ActivityIndicator.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/29/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct ActivityIndicatorProperties: Properties {
  public var core = CoreProperties()

  public var activityIndicatorViewStyle: UIActivityIndicatorViewStyle?
  public var hidesWhenStopped: Bool?
  public var color: UIColor?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)

    activityIndicatorViewStyle = properties.cast("activityIndicatorViewStyle")
    hidesWhenStopped = properties.cast("hidesWhenStopped")
    color = properties.color("color")
  }

  public mutating func merge(_ other: ActivityIndicatorProperties) {
    core.merge(other.core)

    merge(&activityIndicatorViewStyle, other.activityIndicatorViewStyle)
    merge(&hidesWhenStopped, other.hidesWhenStopped)
    merge(&color, other.color)
  }
}

public func ==(lhs: ActivityIndicatorProperties, rhs: ActivityIndicatorProperties) -> Bool {
  return lhs.activityIndicatorViewStyle == rhs.activityIndicatorViewStyle && lhs.hidesWhenStopped == rhs.hidesWhenStopped && lhs.color == rhs.color && lhs.equals(otherProperties: rhs)
}

public class ActivityIndicator: UIActivityIndicatorView, NativeView {
  public weak var eventTarget: AnyObject?
  public lazy var eventRecognizers = EventRecognizers()

  public var properties = ActivityIndicatorProperties() {
    didSet {
      applyCoreProperties()
      applyActivityIndicatorViewProperties()
    }
  }

  public required init() {
    super.init(frame: CGRect.zero)
  }
  
  required public init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func applyActivityIndicatorViewProperties() {
    activityIndicatorViewStyle = properties.activityIndicatorViewStyle ?? .white
    hidesWhenStopped = properties.hidesWhenStopped ?? true
    color = properties.color

    if !isAnimating {
      startAnimating()
    }
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    touchesBegan()
  }
}
