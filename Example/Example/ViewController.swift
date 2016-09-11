//
//  ViewController.swift
//  Example
//
//  Created by Matias Cudich on 8/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import UIKit
import TemplateKit

class ViewController: UIViewController, Context {
  lazy var templateService: TemplateService = XMLTemplateService()

  private var xmlTemplateSevice: XMLTemplateService {
    return templateService as! XMLTemplateService
  }

  var appComponent: App?

  override func viewDidLoad() {
    super.viewDidLoad()

    xmlTemplateSevice.cachePolicy = .never

    templateService.fetchTemplates(withURLs: [Todo.location]) { result in
      DispatchQueue.global(qos: .background).async {
        UIKitRenderer.render(Element(ElementType.component(App.self)), context: self) { [weak self] component, view in
          self?.appComponent = component as? App
          self?.view.addSubview(view)
        }
        self.watchTemplates()
      }
    }
  }

  func watchTemplates() {
    xmlTemplateSevice.watchTemplates(withURLs: [Todo.location]) { result in
      self.appComponent?.update()
    }
  }
}
