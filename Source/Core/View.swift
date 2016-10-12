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

  func add(_ view: View)
  func replace(_ view: View, with newView: View)
}

public protocol ContainerView: class {
  var children: [View] { get set }
}

extension CSSLayout {
  func apply(to view: View) {
    view.frame = frame

    guard let containerView = view as? ContainerView else {
      return
    }

    for (index, child) in children.enumerated() {
      child.apply(to: containerView.children[index])
    }
  }
}
