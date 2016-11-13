//
//  ScrollProxy.swift
//  TemplateKit
//
//  Created by Matias Cudich on 11/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

protocol ScrollProxyDelegate: class {
  func scrollViewDidScroll(_ scrollView: UIScrollView)
}

public class ScrollProxy: NSObject {
  weak var delegate: ScrollProxyDelegate?

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    delegate?.scrollViewDidScroll(scrollView)
  }
}
