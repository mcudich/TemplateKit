//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 9/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

enum Filter {
  case all
  case active
  case completed
}

struct AppState: State {
  var nowShowing = Filter.all
  var editing: String?
  var newTodo: String = ""
}

func ==(lhs: AppState, rhs: AppState) -> Bool {
  return lhs.nowShowing == rhs.nowShowing && lhs.editing == rhs.editing && lhs.newTodo == rhs.newTodo
}

struct AppProperties: ViewProperties {
  var key: String?
  var layout: LayoutProperties?
  var style: StyleProperties?
  var gestures: GestureProperties?

  var model: Todos?

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    model = properties.get("model")
  }
}

func ==(lhs: AppProperties, rhs: AppProperties) -> Bool {
  return lhs.model == rhs.model && lhs.equals(otherViewProperties: rhs)
}

class DataSource: NSObject, TableViewDataSource {
  var model: Todos?

  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    return Element(ElementType.component(Todo.self), ["width": Float(tableView.bounds.size.width)])
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return model?.todos?.count ?? 0
  }
}

class App: CompositeComponent<AppState, AppProperties, UIView> {
  private var todosDataSource = DataSource()

  private lazy var todosList: TableView = {
    let todosList = TableView(frame: CGRect.zero, style: .plain, context: self.getContext())
    todosList.tableViewDataSource = self.todosDataSource
    return todosList
  }()

  override func getInitialState() -> AppState {
    return AppState()
  }

  @objc func handleChange(target: UITextField) {
    updateComponentState { state in
      state.newTodo = target.text ?? ""
    }
  }

  @objc func handleNewTodoSubmit(target: UITextField) {
    properties.model?.addTodo(title: target.text!)
    todosDataSource.model = properties.model
    updateComponentState { state in
      state.newTodo = ""
    }
  }

  func toggleAll(target: UIButton) {
    properties.model?.toggleAll(checked: target.state == .selected)
  }

  func toggle(todo: TodoItem) {
    properties.model?.toggle(id: todo.id)
  }

  func destroy(todo: TodoItem) {
    properties.model?.destroy(id: todo.id)
  }

  func edit(todo: TodoItem) {
    updateComponentState { state in
      state.editing = todo.id
    }
  }

  func save(todo: TodoItem, text: String) {
    properties.model?.save(id: todo.id, title: text)
    cancel()
  }

  func cancel() {
    updateComponentState { state in
      state.editing = nil
    }
  }

  func clearCompleted() {
    properties.model?.clearCompleted()
  }

  override func render() -> Element {
    let _ = properties.model?.todos.filter { todoItem in
      switch state.nowShowing {
      case .active:
        return !todoItem.completed
      case .completed:
        return todoItem.completed
      default:
        return true
      }
    }

    return Element(ElementType.box, ["width": properties.layout?.size?.width, "height": properties.layout?.size?.height], [
      renderHeader(),
      renderMain()
    ])
  }

  private func renderHeader() -> Element {
    return render(withLocation: Bundle.main.url(forResource: "Header", withExtension: "xml")!, properties: ["text": state.newTodo, "onChange": #selector(App.handleChange(target:)), "onSubmit": #selector(App.handleNewTodoSubmit(target:))])
  }

  private func renderMain() -> Element {
    return Element(ElementType.view(todosList), ["flexGrow": Float(1)])
  }
}
