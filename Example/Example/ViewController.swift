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
  let description: String
}

class ViewController: UIViewController {
  fileprivate lazy var client: TemplateClient = {
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
  func node(withName name: String, properties: [String: Any]?) -> Node? {
    return client.node(withName: name, properties: properties)
  }
}

extension ViewController: TableViewTemplateDataSource {
  func tableView(_ tableView: TableView, nodeNameForRowAtIndexPath indexPath: IndexPath) -> String {
    return "Test"
  }

  func tableView(_ tableView: TableView, propertiesForRowAtIndexPath indexPath: IndexPath) -> [String: Any]? {
    return ["model": TestModel(title: "my title", description: "something")]
  }
}

extension ViewController: TableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
}
