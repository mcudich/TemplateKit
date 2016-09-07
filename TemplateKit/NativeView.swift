//
//  NativeView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

typealias GestureHandler = () -> Void

public class EventTarget: NSObject {
  var onTap: GestureHandler?

  public func handleTap() {
    onTap?()
  }
}

public protocol NativeView {
  var eventTarget: EventTarget { get }
}

extension NativeView where Self: UIView {
  func applyCommonProperties(properties: [String: Any]) {
    applyTapHandler(properties)
  }

  private func applyTapHandler(_ properties: [String: Any]) {
    guard let onTap = properties["onTap"] as? GestureHandler else {
      return
    }
    eventTarget.onTap = onTap
    let recognizer = UITapGestureRecognizer(target: eventTarget, action: #selector(EventTarget.handleTap))
    addGestureRecognizer(recognizer)
  }
}
