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
  var appComponent: RemoteApp?

  override func viewDidLoad() {
    super.viewDidLoad()

    NodeRegistry.shared.register(Details.self, for: "details")
    XMLTemplateService.shared.cachePolicy = .never
    XMLTemplateService.shared.fetchTemplates(withURLs: [RemoteApp.location]) { result in
      DispatchQueue.global(qos: .background).async {
        UIKitRenderer.render(Element(ElementType.component(RemoteApp.self))) { [weak self] component, view in
          self?.appComponent = component as? RemoteApp
          self?.view.addSubview(view)
        }
        self.watchTemplates()
      }
    }

//    DispatchQueue.global(qos: .background).async {
//      UIKitRenderer.render(Element(ElementType.component(App.self))) { [weak self] component, view in
//        self?.appComponent = component as? App
//        self?.view.addSubview(view)
//      }
//    }
  }

  func watchTemplates() {
    XMLTemplateService.shared.watchTemplates(withURLs: [RemoteApp.location]) { result in
      self.appComponent?.update()
    }
  }
}
