//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class TableDataSource: NSObject, TableViewDataSource {
  var todoCount = 0

  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    return Element(ElementType.component(Todo.self), ["width": Float(320)])
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todoCount
  }
}

class CollectionDataSource: NSObject, CollectionViewDataSource {
  public func collectionView(_ collectionView: CollectionView, elementAtIndexPath indexPath: IndexPath) -> Element {
    return Element(ElementType.component(Todo.self), ["width": Float(320)])
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return todoCount
  }

  var todoCount = 0
}

struct AppState: State, Equatable {
  var counter = 0
  var showCounter = false
  var flipped = false
  var inputText = ""
}

func ==(lhs: AppState, rhs: AppState) -> Bool {
  return lhs.counter == rhs.counter && lhs.showCounter == rhs.showCounter && lhs.flipped == rhs.flipped && lhs.inputText == rhs.inputText
}

class App: CompositeComponent<AppState, BaseProperties, UIView> {
  private lazy var tableDataSource = TableDataSource()
  private lazy var collectionViewDataSource = CollectionDataSource()

  private lazy var tableView: TableView = {
    let tableView = TableView(frame: CGRect.zero, style: .plain, context: self.getContext())
    tableView.tableViewDataSource = self.tableDataSource
    return tableView
  }()

  private lazy var collectionView: CollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = CollectionView(frame: CGRect.zero, collectionViewLayout: layout, context: self.getContext())
    collectionView.collectionViewDataSource = self.collectionViewDataSource
    return collectionView
  }()

  override func render() -> Element {
    if state.flipped {
      return Element(ElementType.text, ["text": "asdf", "onTap": #selector(App.flip), "marginTop": Float(60)])
    } else {
      return Element(ElementType.box, ["width": Float(320.0), "height": Float(568), "paddingTop": Float(60)], [
        Element(ElementType.textField, ["text": state.inputText, "onChange": #selector(App.handleInputChanged), "height": Float(20)]),
        Element(ElementType.text, ["text": "add", "onTap": #selector(App.incrementCounter)]),
        Element(ElementType.text, ["text": "remove", "onTap": #selector(App.decrementCounter)]),
        Element(ElementType.text, ["text": "flip", "onTap": #selector(App.flip)]),
        Element(ElementType.box, [:], getItems()),
        Element(ElementType.text, ["text": "add todo", "onTap": #selector(App.addTodo)]),
        Element(ElementType.text, ["text": "remove todo", "onTap": #selector(App.removeTodo)]),
        Element(ElementType.component(Details.self), ["message": "\(state.counter)"]),
        Element(ElementType.view(collectionView), ["flexGrow": Float(1)])
      ])
    }
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
    updateComponentState { state in
      state.counter += 1
    }
  }

  @objc func decrementCounter() {
    updateComponentState { state in
      state.counter -= 1
    }
  }

  @objc func flip() {
    updateComponentState { state in
      state.flipped = !self.state.flipped
    }
  }

  @objc func handleInputChanged(sender: UITextField) {
    updateComponentState { state in
      state.inputText = sender.text ?? ""
    }
  }

  @objc func addTodo() {
    collectionViewDataSource.todoCount += 1
    collectionView.insertItems(at: [IndexPath(row: collectionViewDataSource.todoCount - 1, section: 0)])
//    tableView.insertRows(at: [IndexPath(row: collectionViewDataSource.todoCount - 1, section: 0)], with: .left)
  }

  @objc func removeTodo() {
    let rowToDelete = collectionViewDataSource.todoCount - 1
    collectionViewDataSource.todoCount -= 1
    collectionView.deleteItems(at: [IndexPath(row: rowToDelete, section: 0)])
//    tableView.deleteRows(at: [IndexPath(row: rowToDelete, section: 0)], with: .left)
  }
}
