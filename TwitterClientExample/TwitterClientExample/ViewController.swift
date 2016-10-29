//
//  ViewController.swift
//  TwitterClientExample
//
//  Created by Matias Cudich on 10/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import UIKit

import TemplateKit

class ViewController: UIViewController {
  var app: Node?

  override func viewDidLoad() {
    super.viewDidLoad()

    var properties = DefaultProperties()
    properties.core.layout.width = Float(view.bounds.size.width)
    properties.core.layout.height = Float(view.bounds.size.height)

    let templates: [URL] = [TweetItem.templateURL]
    UIKitRenderer.defaultContext.templateService.fetchTemplates(withURLs: templates) { result in
      UIKitRenderer.render(component(App.self, properties), container: self.view, context: nil) { component in
        self.app = component
      }
    }
  }
}
