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
  private lazy var client: TemplateClient = {
    return TemplateClient(fetchStrategy: .local(Bundle.main, nil))
  }()

  private lazy var tableView: TableView = {
    let tableView = TableView(nodeProvider: self, frame: CGRect.zero, style: .plain)

    tableView.templateDataSource = self
    tableView.tableViewDataSource = self
    tableView.tableViewDelegate = self

    return tableView
  }()

  override func loadView() {
    view = tableView
  }
}

extension ViewController: NodeProvider {
  func node(withName name: String) -> Node? {
    return client.node(withName: name)
  }
}

extension ViewController: TableViewTemplateDataSource {
  func tableView(_ tableView: UITableView, nodeNameForRowAtIndexPath indexPath: IndexPath) -> String {
    return "Test"
  }
}

extension ViewController: TableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
}

extension ViewController: TableViewDelegate {
}
