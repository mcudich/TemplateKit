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

    let messageURL = Bundle.main.url(forResource: "Message", withExtension: "xml")!
    TemplateService.shared.fetchTemplates(withURLs: [messageURL]) { result in
      DispatchQueue.main.async {
        self.view.addSubview(self.appNode.render())
      }
    }
  }
}
