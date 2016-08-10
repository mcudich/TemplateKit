//
//  DelegateProxy.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class DelegateProxy: NSObject {
  private let target: NSObjectProtocol?
  private let interceptor: NSObjectProtocol?
  private lazy var selectors = Set<Selector>()

  init(target: NSObjectProtocol?, interceptor: NSObjectProtocol?) {
    self.target = target
    self.interceptor = interceptor
  }

  func registerInterceptable(selector: Selector) {
    selectors.insert(selector)
  }

  override func conformsToProtocol(aProtocol: Protocol) -> Bool {
    return true
  }

  override func respondsToSelector(aSelector: Selector) -> Bool {
    if intercepts(aSelector) {
      return interceptor?.respondsToSelector(aSelector) ?? false
    } else {
      return target?.respondsToSelector(aSelector) ?? false
    }
  }

  override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
    if intercepts(aSelector) {
      return interceptor
    } else if let target = target {
      return target.respondsToSelector(aSelector) ? target : nil
    }
    return nil
  }

  private func intercepts(selector: Selector) -> Bool {
    return selectors.contains(selector)
  }
}