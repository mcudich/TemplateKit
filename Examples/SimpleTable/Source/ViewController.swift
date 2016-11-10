//
//  ViewController.swift
//  SimpleTable
//
//  Created by Matias Cudich on 11/3/16.
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

    let templates: [URL] = [Item.templateURL, Bundle.main.url(forResource: "Header", withExtension: "xml")!]
    UIKitRenderer.defaultContext.templateService.fetchTemplates(withURLs: templates) { result in
      UIKitRenderer.render(component(App.self, properties), container: self.view, context: nil) { component in
        self.app = component
      }
    }
  }
}
