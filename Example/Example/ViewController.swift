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
  var appComponent: App?

  lazy var templateService: TemplateService = {
    let templateService = XMLTemplateService(liveReload: true)
    templateService.cachePolicy = .never
    templateService.liveReloadInterval = .seconds(1)
    return templateService
  }()

  var updateQueue: DispatchQueue {
    return UIKitRenderer.defaultContext.updateQueue
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    templateService.fetchTemplates(withURLs: [Todo.location]) { result in
      DispatchQueue.global(qos: .background).async {
        UIKitRenderer.render(Element(ElementType.component(App.self)), container: self.view, context: self) { component in
          self.appComponent = component as? App
        }
      }
    }
  }
}
