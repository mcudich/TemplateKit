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
    return TemplateClient(fetchStrategy: .Local(NSBundle.mainBundle(), nil))
  }()

  private lazy var tableView: TableView = {
    let tableView = TableView(nodeProvider: self, frame: CGRect.zero, style: .Plain)

    tableView.templateDataSource = self
    tableView.tableDataSource = self
    tableView.tableDelegate = self

    return tableView
  }()

  override func loadView() {
    view = tableView
  }
}

extension ViewController: NodeProvider {
  func nodeWithName(name: String) -> Node? {
    return client.nodeWithName(name)
  }
}

extension ViewController: TableViewTemplateDataSource {
  func tableView(tableView: UITableView, nodeNameForRowAtIndexPath indexPath: NSIndexPath) -> String {
    return "Test"
  }
}

extension ViewController: TableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
}

extension ViewController: TableViewDelegate {

}
