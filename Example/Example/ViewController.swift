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
  override func viewDidLoad() {
    super.viewDidLoad()

    let app = App(properties: [:])
    DispatchQueue.global(qos: .background).async {
      app.render { appView in
        self.view.addSubview(appView)
      }
    }
  }
}
