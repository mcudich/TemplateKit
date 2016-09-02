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
  var appNode = App(properties: [:])

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(appNode.render())
  }
}
