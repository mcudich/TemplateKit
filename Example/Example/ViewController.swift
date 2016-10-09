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
    return templateService
  }()

  var updateQueue: DispatchQueue {
    return UIKitRenderer.defaultContext.updateQueue
  }

  private var app: App?

  override func viewDidLoad() {
    super.viewDidLoad()

    var properties = AppProperties()
    properties.core.layout.width = Float(view.bounds.size.width)
    properties.core.layout.height = Float(view.bounds.size.height)
    properties.model = Todos()

    let templateURLs = [
      Bundle.main.url(forResource: "Header", withExtension: "xml")!,
      Bundle.main.url(forResource: "Footer", withExtension: "xml")!,
      Bundle.main.url(forResource: "Todo", withExtension: "xml")!
    ]

    NodeRegistry.shared.registerComponent(CountText.self, CountTextProperties.self)

    templateService.fetchTemplates(withURLs: templateURLs) { result in
      DispatchQueue.global(qos: .background).async {
        UIKitRenderer.render(component(App.self, properties), container: self.view, context: self) { component in
          self.app = component as? App
        }
      }
    }
  }
}
