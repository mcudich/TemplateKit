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
  var appNode: App?

  override func viewDidLoad() {
    super.viewDidLoad()

    NodeRegistry.shared.register(Details.self, for: "details")
    TemplateService.shared.fetchTemplates(withURLs: [RemoteApp.location]) { result in
      DispatchQueue.global(qos: .background).async {
        UIKitRenderer.render(Element(ElementType.node(RemoteApp.self))) { [weak self] appNode, appView in
          self?.appNode = appNode as? App
          self?.view.addSubview(appView)
        }
      }
    }

//    DispatchQueue.global(qos: .background).async {
//      UIKitRenderer.render(Element(ElementType.node(App.self))) { [weak self] appNode, appView in
//        self?.appNode = appNode as? App
//        self?.view.addSubview(appView)
//      }
//    }
  }
}
