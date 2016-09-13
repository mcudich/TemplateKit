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
  var appComponent: App?
  var templateService: XMLTemplateService? {
    return UIKitRenderer.defaultContext.templateService as? XMLTemplateService
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    templateService?.cachePolicy = .never

    templateService?.fetchTemplates(withURLs: [Todo.location]) { result in
      DispatchQueue.global(qos: .background).async {
        UIKitRenderer.render(Element(ElementType.component(App.self))) { [weak self] component, view in
          self?.appComponent = component as? App
          self?.view.addSubview(view)
        }
        self.watchTemplates()
      }
    }
  }

  func watchTemplates() {
    templateService?.watchTemplates(withURLs: [Todo.location]) { result in
      self.appComponent?.update()
    }
  }
}
