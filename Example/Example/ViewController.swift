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

  func getRenderer<T : Renderer>() -> T {
    return UIKitRenderer
  }

  var appComponent: RemoteApp?

  override func viewDidLoad() {
    super.viewDidLoad()

    NodeRegistry.shared.register(Details.self, for: "details")
    xmlTemplateSevice.cachePolicy = .never
    templateService.fetchTemplates(withURLs: [RemoteApp.location]) { result in
      switch result {
      case .success:
        DispatchQueue.global(qos: .background).async {
          UIKitRenderer.render(Element(ElementType.component(RemoteApp.self)), context: self) { [weak self] component, view in
            self?.appComponent = component as? RemoteApp
            self?.view.addSubview(view)
          }
          self.watchTemplates()
        }
      case .error(let error):
        fatalError(error.localizedDescription)
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
    xmlTemplateSevice.watchTemplates(withURLs: [RemoteApp.location]) { result in
      self.appComponent?.update()
    }
  }
}
