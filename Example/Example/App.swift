//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct App: Node {
  var properties: [String : Any]
  var calculatedFrame: CGRect?

  init(properties: [String : Any]) {
    self.properties = properties
  }

  func build(completion: (Node) -> Void) {
    let app = Box(properties: ["width": CGFloat(320), "height": CGFloat(500)]) {
      [Text(properties: ["text": "foo"])]
    }
    completion(app)
  }

  func sizeThatFits(_ size: CGSize, completion: (CGSize) -> Void) {
    build { (var root) in
      root.sizeThatFits(size, completion: completion)
    }
  }
}
