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
  var appNode: Node?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    let provider = { properties in
      return ViewNode<TodoList>(properties: properties)
    }
    NodeRegistry.shared.register(nodeInstanceProvider: provider, forIdentifier: "TodoList")
    NodeRegistry.shared.register(propertyTypes: NodeRegistry.defaultPropertyTypes, forIdentifier: "TodoList")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let location = Bundle.main.url(forResource: "App", withExtension: "xml")!
    let properties: [String: Any] = [
      "width": view.bounds.width,
      "height": view.bounds.height,
      "onTapAddRow": onTapAddRow
    ]
    TemplateService.shared.node(withLocation: location, properties: properties) { result in
      switch result {
      case .success(let node):
        self.appNode = node
        node.sizeToFit(self.view.bounds.size)
        DispatchQueue.main.async {
          self.view.addSubview(node.render())
        }
      case .error(let error):
        fatalError(error.localizedDescription)
      }
    }
  }

  func onTapAddRow() {

  }
}
