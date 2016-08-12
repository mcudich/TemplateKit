//
//  Dictionary.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension Dictionary {
  mutating func merge(with dictionary: Dictionary) {
    for (key, value) in dictionary {
      self[key] = value
    }
  }
}
