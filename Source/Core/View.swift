//
//  View.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/18/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol View: Layoutable {
  var frame: CGRect { get set }
  var superview: UIView? { get }

  func addSubview(_ view: View)
  func replace(_ view: View, with newView: View)
}
