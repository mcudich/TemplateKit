//
//  ViewController.swift
//  Example
//
//  Created by Matias Cudich on 8/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import UIKit
import TemplateKit

class ViewController: UIViewController {
  private lazy var client: TemplateClient = {
    return TemplateClient(fetchStrategy: .Local(NSBundle.mainBundle(), nil))
  }()

  override func viewDidLoad() {
    let node = client.nodeWithName("Test")
    if let node = node {
      node.frame.size = node.measure(view.bounds.size)
      let nodeView = node.render()
      view.addSubview(nodeView)
    }
  }
}
