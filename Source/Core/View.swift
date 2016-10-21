//
//  View.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/18/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

public protocol View: class {
  var frame: CGRect { get set }
  var parent: View? { get }
  var children: [View] { get set }

  func add(_ view: View)
  func replace(_ view: View, with newView: View)
}

extension CSSLayout {
  func apply(to view: View) {
    view.frame = frame

    for (index, child) in children.enumerated() {
      child.apply(to: view.children[index])
    }
  }
}
