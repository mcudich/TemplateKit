//
//  DelegateProxy.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

protocol DelegateProxyProtocol {
  init(target: AnyObject?, interceptor: NSObjectProtocol?)
  func registerInterceptable(selector: Selector)
}

class DelegateProxy: NSObject, DelegateProxyProtocol {
  fileprivate let target: AnyObject?
  fileprivate let interceptor: NSObjectProtocol?
  private lazy var selectors = Set<Selector>()

  required init(target: AnyObject?, interceptor: NSObjectProtocol?) {
    self.target = target
    self.interceptor = interceptor
  }

  func registerInterceptable(selector: Selector) {
    selectors.insert(selector)
  }

  override func conforms(to aProtocol: Protocol) -> Bool {
    return true
  }

  override func responds(to aSelector: Selector) -> Bool {
    if intercepts(selector: aSelector) {
      return interceptor?.responds(to: aSelector) ?? false
    } else {
      return target?.responds(to: aSelector) ?? false
    }
  }

  override func forwardingTarget(for aSelector: Selector) -> Any? {
    if intercepts(selector: aSelector) {
      return interceptor
    } else if let target = target {
      return target.responds(to: aSelector) ? target : nil
    }
    return nil
  }

  private func intercepts(selector: Selector) -> Bool {
    return selectors.contains(selector)
  }
}

func ==(lhs: DelegateProxy, rhs: DelegateProxy) -> Bool {
  return lhs.target === rhs.target && lhs.interceptor === rhs.interceptor
}
