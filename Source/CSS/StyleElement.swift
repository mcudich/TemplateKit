//
//  StyleElement.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol StyleElement {
  var id: String? { get }
  var classNames: [String]? { get }
  var tagName: String? { get }
  var parent: StyleElement? { get }
  var children: [StyleElement]? { get }
}
