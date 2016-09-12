//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class DataSource: NSObject, TableViewDataSource {
  var todoCount = 0

  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    return Element(ElementType.component(Todo.self), ["width": Float(320)])
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todoCount
  }
}

struct AppState: State {
  var counter = 0
  var showCounter = false
  var flipped = false
  var inputText = ""
}

class App: CompositeComponent<AppState> {
  private lazy var dataSource = DataSource()

  private lazy var tableView: TableView = {
    let tableView = TableView(frame: CGRect.zero, style: .plain, context: self.getContext())
    tableView.tableViewDataSource = self.dataSource
    return tableView
  }()

  override func render() -> Element {
    return Element(ElementType.box, ["width": Float(320.0), "height": Float(568), "paddingTop": Float(60)], [
      Element(ElementType.textField, ["text": state.inputText, "onChange": #selector(App.handleInputChanged), "height": Float(20)]),
      Element(ElementType.text, ["text": "add", "onTap": #selector(App.incrementCounter)]),
      Element(ElementType.text, ["text": "remove", "onTap": #selector(App.decrementCounter)]),
      Element(ElementType.text, ["text": "flip", "onTap": #selector(App.flip)]),
      Element(ElementType.box, [:], getItems()),
      Element(ElementType.text, ["text": "add todo", "onTap": #selector(App.addTodo)]),
      Element(ElementType.text, ["text": "remove todo", "onTap": #selector(App.removeTodo)]),
      Element(ElementType.component(Details.self), ["message": "\(state.counter)"]),
      Element(ElementType.view(tableView), ["flexGrow": Float(1)])
    ])
  }

  func getKey(index: Int) -> String {
    return ["foo", "bar", "baz", "blah", "flah", "asdf"][index]
  }

  func getItems() -> [Element] {
    let items = (0..<state.counter).map {
      return Element(ElementType.text, ["text": "\($0)", "key": getKey(index: $0)])
    }
    if state.flipped {
      return items.reversed()
    } else {
      return items
    }
  }

  @objc func incrementCounter() {
    updateState {
      self.state.counter += 1
      return self.state
    }
  }

  @objc func decrementCounter() {
    updateState {
      self.state.counter -= 1
      return self.state
    }
  }

  @objc func flip() {
    updateState {
      self.state.flipped = !self.state.flipped
      return self.state
    }
  }

  @objc func handleInputChanged(sender: UITextField) {
    updateState {
      self.state.inputText = sender.text ?? ""
      return self.state
    }
  }

  @objc func addTodo() {
    dataSource.todoCount += 1
    tableView.insertRows(at: [IndexPath(row: dataSource.todoCount - 1, section: 0)], with: .left)
  }

  @objc func removeTodo() {
    let rowToDelete = dataSource.todoCount - 1
    dataSource.todoCount -= 1
    tableView.deleteRows(at: [IndexPath(row: rowToDelete, section: 0)], with: .left)
  }
}
