//
//  Interpolator.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/22/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Interpolator {
  func interpolate<T: Interpolatable>(_ fromValue: T, _ toValue: T, _ elapsed: TimeInterval, _ duration: TimeInterval) -> T
}
