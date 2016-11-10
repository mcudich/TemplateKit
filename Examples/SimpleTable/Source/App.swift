//
//  App.swift
//  SimpleTable
//
//  Created by Matias Cudich on 11/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

import TemplateKit
import CSSLayout

struct AppState: State {
  var items = [TableSection]()
}

func ==(lhs: AppState, rhs: AppState) -> Bool {
  return lhs.items.count == rhs.items.count
}

class App: Component<AppState, DefaultProperties, UIView> {

  @objc func addSection() {
    updateState { state in
      state.items.append(TableSection(items: ["a"], hashValue: 1))
    }
  }

  @objc func removeSection() {

  }

  override func render() -> Template {
    var properties = DefaultProperties()
    properties.core.layout = self.properties.core.layout

    let tree = box(properties, [
      renderHeader(),
      renderItems()
    ])

    return Template(tree)
  }

  private func renderHeader() -> Element {
    return render(Bundle.main.url(forResource: "Header", withExtension: "xml")!).build(with: self)
  }

  private func renderItems() -> Element {
    var properties = TableProperties()
    properties.core.layout.flex = 1
    properties.tableViewDataSource = self
    properties.items = state.items

    return table(properties)
  }

  override func getInitialState() -> AppState {
    var state = AppState()
    state.items = [TableSection(items: ["1"], hashValue: 0)]
    return state
  }
}

extension App: TableViewDataSource {
  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    var properties = ItemProperties()
    properties.item = state.items[indexPath.section].items[indexPath.row] as? String
    properties.core.layout.width = self.properties.core.layout.width
    return component(Item.self, properties)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return state.items[section].items.count
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return state.items.count
  }
}
