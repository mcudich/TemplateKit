//
//  String.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/26/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension String {
  func capitalizingFirstLetter() -> String {
    let first = String(characters.prefix(1)).capitalized
    let other = String(characters.dropFirst())
    return first + other
  }
}
