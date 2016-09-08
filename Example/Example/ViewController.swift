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
//  var appNode: App?

  private lazy var tableView: TableView = {
    let tableView = TableView(frame: CGRect.zero, style: .plain)
    tableView.tableViewDataSource = self
    return tableView
  }()

  override func loadView() {
    view = tableView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

//    DispatchQueue.global(qos: .background).async {
//      UIKitRenderer.render(Element(ElementType.node(App.self))) { [weak self] appNode, appView in
//        self?.appNode = appNode as? App
//        self?.view.addSubview(appView)
//      }
//    }
  }
}

extension ViewController: TableViewDataSource {
  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    return Element(ElementType.node(Todo.self), ["width": view.bounds.width])
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
  }
}
