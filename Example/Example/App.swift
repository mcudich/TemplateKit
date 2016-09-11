//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class App: NSObject, Component {
  public weak var owner: Component?
  public var currentInstance: Node?
  public var currentElement: Element?
  public var properties: [String : Any]
  public var state: Any? = State()
  public var context: Context?

  fileprivate var todoCount = 0

  struct State {
    var counter = 0
    var showCounter = false
    var flipped = false
    var inputText = ""
  }

  private var appState: State {
    get {
      return state as! State
    }
    set {
      state = newValue
    }
  }

  private lazy var tableView: TableView = {
    let tableView = TableView(frame: CGRect.zero, style: .plain, context: self.getContext())
    tableView.tableViewDataSource = self
    return tableView
  }()


  required init(properties: [String : Any], owner: Component?) {
    self.properties = properties
    self.owner = owner
  }

  func render() -> Element {
    return Element(ElementType.box, ["width": Float(320.0), "height": Float(568), "paddingTop": Float(60)], [
      Element(ElementType.textField, ["text": appState.inputText, "onChange": #selector(App.handleInputChanged), "height": Float(20)]),
      Element(ElementType.text, ["text": "add", "onTap": #selector(App.incrementCounter)]),
      Element(ElementType.text, ["text": "remove", "onTap": #selector(App.decrementCounter)]),
      Element(ElementType.text, ["text": "flip", "onTap": #selector(App.flip)]),
      Element(ElementType.box, [:], getItems()),
      Element(ElementType.text, ["text": "add todo", "onTap": #selector(App.addTodo)]),
      Element(ElementType.text, ["text": "remove todo", "onTap": #selector(App.removeTodo)]),
      Element(ElementType.component(Details.self), ["message": "\(appState.counter)"]),
      Element(ElementType.view(tableView), ["flexGrow": Float(1)])
    ])
  }

  func getKey(index: Int) -> String {
    return ["foo", "bar", "baz", "blah", "flah", "asdf"][index]
  }

  func getItems() -> [Element] {
    let items = (0..<appState.counter).map {
      return Element(ElementType.text, ["text": "\($0)", "key": getKey(index: $0)])
    }
    if appState.flipped {
      return items.reversed()
    } else {
      return items
    }
  }

  @objc func incrementCounter() {
    updateState {
      appState.counter += 1
      return appState
    }
  }

  @objc func decrementCounter() {
    updateState {
      appState.counter -= 1
      return appState
    }
  }

  @objc func flip() {
    updateState {
      appState.flipped = !appState.flipped
      return appState
    }
  }

  @objc func handleInputChanged(sender: UITextField) {
    updateState {
      appState.inputText = sender.text ?? ""
      return appState
    }
  }

  @objc func addTodo() {
    todoCount += 1
    tableView.insertRows(at: [IndexPath(row: todoCount - 1, section: 0)], with: .left)
  }

  @objc func removeTodo() {
    let rowToDelete = todoCount - 1
    todoCount -= 1
    tableView.deleteRows(at: [IndexPath(row: rowToDelete, section: 0)], with: .left)
  }
}

extension App: TableViewDataSource {
  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    return Element(ElementType.component(Todo.self), ["width": Float(320)])
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todoCount
  }
}
