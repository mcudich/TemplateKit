//
//  Table.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/2/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class View: LeafNode {
  public var root: Node?
  public var renderedView: UIView?
  public let properties: [String: Any]
  public var state: Any?
  public var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  public init(properties: [String: Any], view: UIView) {
    self.properties = properties
    self.renderedView = view
  }

  public required init(properties: [String : Any]) {
    self.properties = properties
  }

  public func buildView() -> UIView {
    return renderedView!
  }

  public func applyProperties(to view: UIView) {
  }
}

extension View: Layoutable {
}
