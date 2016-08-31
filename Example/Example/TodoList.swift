//
//  TodoList.swift
//  Example
//
//  Created by Matias Cudich on 8/30/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct Todo: Model {
  let description: String
}

class TodoList: NSObject {
  var calculatedFrame: CGRect?
  weak var propertyProvider: PropertyProvider?

  fileprivate lazy var todos = [Todo]()

  fileprivate lazy var tableView: TableView = {
    let tableView = TableView(nodeProvider: self, frame: CGRect.zero, style: .plain)
    tableView.tableViewDataSource = self
    return tableView
  }()

  required override init() {
    super.init()
  }
}

extension TodoList: NodeProvider {
  func node(withLocation location: URL, properties: [String : Any]?, completion: NodeResultHandler) {
    return TemplateService.shared.node(withLocation: location, properties: properties, completion: completion)
  }
}

extension TodoList: TableViewDataSource {
  func tableView(_ tableView: TableView, locationForNodeAtIndexPath indexPath: IndexPath) -> URL {
    return Bundle.main.url(forResource: "Todo", withExtension: "xml")!
  }

  func tableView(_ tableView: TableView, propertiesForRowAtIndexPath indexPath: IndexPath) -> [String: Any]? {
    return ["model": todos[indexPath.row]]
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todos.count
  }
}

extension TodoList: View {
  func render() -> UIView {
    return tableView
  }

  func sizeThatFits(_ size: CGSize) -> CGSize {
    return tableView.sizeThatFits(size)
  }
}

extension TodoList: FlexNodeProvider {}
