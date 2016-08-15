//
//  ViewNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class ViewNode<V: View>: Node {
  public static var propertyTypes: [String : ValidationType] {
    return V.propertyTypes
  }

  public var properties: [String: Any]?
  public var model: Model?

  public lazy var view: View = {
    var view = V()
    view.propertyProvider = self
    return view
  }()

  public func render() -> UIView {
    let frame = view.calculatedFrame ?? CGRect.zero
    let renderedView = view.render()
    renderedView.frame = frame
    return renderedView
  }

  public func sizeThatFits(_ size: CGSize) -> CGSize {
    return view.sizeThatFits(size)
  }

  public func sizeToFit(_ size: CGSize) {
    view.sizeToFit(size)
  }
}
