//
//  ViewNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

public class ViewNode<V: View>: Node {
  public var root: Node?
  public var renderedView: UIView?
  public let properties: [String: Any]
  public var state: Any?
  public var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  public lazy var view: View = {
    var view = V()

//    view.propertyProvider = self

    if let tapHandler = self.properties["onTap"] {
      view.addTapHandler(target: self, action: #selector(handleTap))
    }

    return view
  }()

  public required init(properties: [String : Any]) {
    self.properties = properties
  }

  public func build(completion: (Node) -> Void) {
    completion(self)
  }

  public func render() -> UIView {
    let frame = view.calculatedFrame ?? CGRect.zero
    let renderedView = view.render()
    renderedView.frame = frame
    return renderedView
  }

  public func render(completion: @escaping (UIView) -> Void) {
    
  }

  public func sizeThatFits(_ size: CGSize) -> CGSize {
    return view.sizeThatFits(size)
  }

  public func sizeThatFits(_ size: CGSize, completion: (CGSize) -> Void) {
    
  }

  public func sizeToFit(_ size: CGSize) {
    view.sizeToFit(size)
  }

  @objc private func handleTap(sender: Any) {
    guard let tapHandler = properties["onTap"] as? (() -> Void) else {
      return
    }

    tapHandler()
  }
}
