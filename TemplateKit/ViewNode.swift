//
//  ViewNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class ViewNode<V: View>: Node {
  public static var propertyTypes: [String : Validator] {
    return V.propertyTypes
  }

  public var properties: [String: Any]? {
    didSet {
      invalidate()
    }
  }
  public var model: Model? {
    didSet {
      invalidate()
    }
  }

  public lazy var view: View = {
    var view = V()
    view.propertyProvider = self
    return view
  }()

  public func render() -> UIView {
    let frame = view.calculatedFrame ?? CGRectZero
    let renderedView = view.render()
    renderedView.frame = frame
    return renderedView
  }

  public func sizeThatFits(size: CGSize) -> CGSize {
    return view.sizeThatFits(size)
  }

  public func sizeToFit(size: CGSize) {
    view.sizeToFit(size)
  }
}

extension ViewNode: PropertyProvider {
  public func get<T>(key: String) -> T? {
    return properties?[key] as? T
  }
}
