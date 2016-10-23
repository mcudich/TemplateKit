//
//  Bezier.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/22/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

// Based on:
// https://github.com/WebKit/webkit/blob/master/Source/WebCore/platform/graphics/UnitBezier.h
struct UnitBezier {
  let cx: Double
  let bx: Double
  let ax: Double
  let cy: Double
  let by: Double
  let ay: Double

  init(p1x: Double, p1y: Double, p2x: Double, p2y: Double) {
    // Calculate the polynomial coefficients, implicit first and last control points are (0,0) and (1,1).
    cx = 3.0 * p1x;
    bx = 3.0 * (p2x - p1x) - cx;
    ax = 1.0 - cx - bx;

    cy = 3.0 * p1y;
    by = 3.0 * (p2y - p1y) - cy;
    ay = 1.0 - cy - by;
  }

  func solve(_ x: Double, epsilon: Double) -> Double {
    return sampleCurveY(solveCurveX(x, epsilon: epsilon));
  }

  private func sampleCurveX(_ t: Double) -> Double {
    // `ax t^3 + bx t^2 + cx t' expanded using Horner's rule.
    return ((ax * t + bx) * t + cx) * t;
  }

  private func sampleCurveY(_ t: Double) -> Double {
    return ((ay * t + by) * t + cy) * t;
  }

  private func sampleCurveDerivativeX(_ t: Double) -> Double {
    return (3.0 * ax * t + 2.0 * bx) * t + cx;
  }

    // Given an x value, find a parametric value it came from.
  private func solveCurveX(_ x: Double, epsilon: Double) -> Double {
    var t0: Double;
    var t1: Double;
    var t2 = x;
    var x2: Double;
    var d2: Double;

    // First try a few iterations of Newton's method -- normally very fast.
    for _ in 0..<8 {
      x2 = sampleCurveX(t2) - x;
      if fabs(x2) < epsilon {
        return t2;
      }
      d2 = sampleCurveDerivativeX(t2);
      if fabs(d2) < 1e-6 {
        break;
      }
      t2 = t2 - x2 / d2;
    }

    // Fall back to the bisection method for reliability.
    t0 = 0.0;
    t1 = 1.0;
    t2 = x;

    if t2 < t0 {
      return t0;
    }
    if t2 > t1 {
      return t1;
    }

    while t0 < t1 {
      x2 = sampleCurveX(t2);
      if fabs(x2 - x) < epsilon {
        return t2;
      }
      if x > x2 {
        t0 = t2;
      } else {
        t1 = t2;
        t2 = (t1 - t0) * 0.5 + t0;
      }
    }

    // Failure.
    return t2;
  }
}
