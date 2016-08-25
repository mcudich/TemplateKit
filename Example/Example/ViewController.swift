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
  fileprivate lazy var client = TemplateService()

  fileprivate lazy var tableView: TableView = {
    let tableView = TableView(nodeProvider: self, frame: CGRect.zero, style: .plain)

    tableView.tableViewDataSource = self

    return tableView
  }()

  override func loadView() {
    view = tableView
  }
}

extension ViewController: NodeProvider {
  func node(withLocation location: URL, properties: [String : Any]?, completion: NodeResultHandler) {
    return client.node(withLocation: location, properties: properties, completion: completion)
  }
}

extension ViewController: TableViewDataSource {
  func tableView(_ tableView: TableView, locationForNodeAtIndexPath indexPath: IndexPath) -> URL {
    return Bundle.main.url(forResource: "Test", withExtension: "xml")!
  }

  func tableView(_ tableView: TableView, propertiesForRowAtIndexPath indexPath: IndexPath) -> [String: Any]? {
    return ["model": TestModel(title: "my title", description: "something"), "foo": "bar"]
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 100
  }
}
