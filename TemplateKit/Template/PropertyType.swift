//
//  PropertyType.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol PropertyTypeProvider {
  static var propertyTypes: [String: ValidationType] { get }
}
