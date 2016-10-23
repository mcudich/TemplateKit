//
//  BezierInterpolator.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/22/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension CAMediaTimingFunction {
  @nonobjc public static let linear = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
  @nonobjc public static let easeIn = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
  @nonobjc public static let easeOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
  @nonobjc public static let easeInEaseOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

  // See http://easings.net.
  @nonobjc public static let easeInQuad = CAMediaTimingFunction(controlPoints: 0.55, 0.085, 0.68, 0.53)
  @nonobjc public static let easeOutQuad = CAMediaTimingFunction(controlPoints: 0.25, 0.46, 0.45, 0.94)
  @nonobjc public static let easeInOutQuad = CAMediaTimingFunction(controlPoints: 0.455, 0.03, 0.515, 0.955)

  @nonobjc public static let easeInCubic = CAMediaTimingFunction(controlPoints: 0.55, 0.055, 0.675, 0.19)
  @nonobjc public static let easeOutCubic = CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1)
  @nonobjc public static let easeInOutCubic = CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)

  @nonobjc public static let easeInQuart = CAMediaTimingFunction(controlPoints: 0.895, 0.03, 0.685, 0.22)
  @nonobjc public static let easeOutQuart = CAMediaTimingFunction(controlPoints: 0.165, 0.84, 0.44, 1)
  @nonobjc public static let easeInOutQuart = CAMediaTimingFunction(controlPoints: 0.77, 0, 0.175, 1)

  @nonobjc public static let easeInQuint = CAMediaTimingFunction(controlPoints: 0.755, 0.05, 0.855, 0.06)
  @nonobjc public static let easeOutQuint = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
  @nonobjc public static let easeInOutQuint = CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1)

  @nonobjc public static let easeInExpo = CAMediaTimingFunction(controlPoints: 0.95, 0.05, 0.795, 0.035)
  @nonobjc public static let easeOutExpo = CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)
  @nonobjc public static let easeInOutExpo = CAMediaTimingFunction(controlPoints: 1, 0, 0, 1)

  @nonobjc public static let easeInCirc = CAMediaTimingFunction(controlPoints: 0.6, 0.04, 0.98, 0.335)
  @nonobjc public static let easeOutCirc = CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)
  @nonobjc public static let easeInOutCirc = CAMediaTimingFunction(controlPoints: 0.785, 0.135, 0.15, 0.86)

  @nonobjc public static let easeInBack = CAMediaTimingFunction(controlPoints: 0.6, -0.28, 0.735, 0.045)
  @nonobjc public static let easeOutBack = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
  @nonobjc public static let easeInOutBack = CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.265, 1.55)
}

public class BezierInterpolator: Interpolator {
  private lazy var timingControlPoints: [Double] = [0, 0, 0, 0]

  public init(_ timingFunction: CAMediaTimingFunction = .linear) {
    configure(with: timingFunction)
  }

  public func interpolate<T: Interpolatable>(_ fromValue: T, _ toValue: T, _ elapsed: TimeInterval, _ duration: TimeInterval) -> T {
    let progress = elapsed / duration
    let bezier = UnitBezier(p1x: timingControlPoints[0], p1y: timingControlPoints[1], p2x: timingControlPoints[2], p2y: timingControlPoints[3])
    let epsilon = 1 / (1000 * duration)
    let p = bezier.solve(progress, epsilon: epsilon)

    return T.interpolate(fromValue, toValue, p)
  }

  private func configure(with timingFunction: CAMediaTimingFunction) {
    var points = Array<Float>(repeating: 0, count: 4)
    timingFunction.getControlPoint(at: 1, values: &points[0])
    timingFunction.getControlPoint(at: 2, values: &points[2])
    for (index, _) in points.enumerated() {
      timingControlPoints[index] = Double(points[index])
    }
  }
}
