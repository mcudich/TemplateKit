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
  lazy var templateService: TemplateService = {
    let templateService = XMLTemplateService(liveReload: false)
    templateService.cachePolicy = .never
    templateService.liveReloadInterval = .seconds(1)
    return templateService
  }()

  var updateQueue: DispatchQueue {
    return UIKitRenderer.defaultContext.updateQueue
  }

  private var app: App?

  override func viewDidLoad() {
    super.viewDidLoad()

    let appProperties = ["width": Float(view.bounds.size.width), "height": Float(view.bounds.size.height)]
    templateService.fetchTemplates(withURLs: [Bundle.main.url(forResource: "Header", withExtension: "xml")!]) { result in
      DispatchQueue.global(qos: .background).async {
        UIKitRenderer.render(Element(ElementType.component(App.self), appProperties), container: self.view, context: self) { component in
          self.app = component as? App
        }
      }
    }
  }
}
