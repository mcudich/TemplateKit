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
  override func viewDidLoad() {
    super.viewDidLoad()

    DispatchQueue.global(qos: .background).async {
      UIKitRenderer.render(Element(ElementType.node(App.self))) { [weak self] appView in
        self?.view.addSubview(appView)
      }
    }
  }
}
