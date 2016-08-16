//
//  ViewController.swift
//  Example
//
//  Created by Matias Cudich on 8/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import UIKit
import TemplateKit

struct TestModel: Model {
  let title: String
}

class ViewController: UIViewController {
  private lazy var client: TemplateClient = {
    return TemplateClient(fetchStrategy: .local(Bundle.main, nil))
  }()

  private lazy var tableView: TableView = {
    let tableView = TableView(nodeProvider: self, frame: CGRect.zero, style: .plain)

    tableView.templateDataSource = self
    tableView.tableViewDataSource = self

    return tableView
  }()

  override func loadView() {
    view = tableView
  }
}

extension ViewController: NodeProvider {
  func node(withName name: String, model: Model?) -> Node? {
    return client.node(withName: name, model: model)
  }
}

extension ViewController: TableViewTemplateDataSource {
  func tableView(_ tableView: TableView, nodeNameForRowAtIndexPath indexPath: IndexPath) -> String {
    return "Test"
  }

  func tableView(_ tableView: TableView, modelForRowAtIndexPath indexPath: IndexPath) -> Model? {
    return TestModel(title: "my title")
  }
}

extension ViewController: TableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
}

