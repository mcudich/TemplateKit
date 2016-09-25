//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 9/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

enum Filter: Int {
  case all = 0
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
  var layout = LayoutProperties()
  var style = StyleProperties()
  var gestures = GestureProperties()

  var model: Todos?

  public init() {}

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    model = properties.get("model")
  }
}

func ==(lhs: AppProperties, rhs: AppProperties) -> Bool {
  return lhs.model == rhs.model && lhs.equals(otherViewProperties: rhs)
}

extension App: TableViewDataSource {
  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    var properties = TodoProperties()

    properties.todo = getFilteredTodos()[indexPath.row]
    properties.layout.width = self.properties.layout.width
    properties.onToggle = #selector(App.handleToggle(id:))
    properties.onSave = #selector(App.handleSave(id:text:))
    properties.onEdit = #selector(App.handleEdit(id:))
    properties.onDestroy = #selector(App.handleDestroy(id:))

    return ElementData(ElementType.component(Todo.self), properties)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return getFilteredTodos().count
  }
}

class App: CompositeComponent<AppState, AppProperties, UIView> {
  private lazy var todosList: TableView = {
    let todosList = TableView(frame: CGRect.zero, style: .plain, context: self.getContext())
    todosList.tableViewDataSource = self
    todosList.eventTarget = self
    todosList.allowsSelection = false
    return todosList
  }()

  required init(element: Element, children: [Node]?, owner: Node?) {
    super.init(element: element, children: children, owner: owner)

    self.properties.model?.subscribe { [weak self] in
      // Properties have changed, but have not gotten re-set on this component. Force an update.
      self?.forceUpdate()
      self?.todosList.reloadData()
    }
  }

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
    updateComponentState { state in
      state.newTodo = ""
    }
  }

  @objc func handleToggleAll(target: UIButton) {
    properties.model?.toggleAll(checked: target.state.contains(.selected))
  }

  @objc func handleUpdateFilter(filter: NSNumber) {
    guard let filter = Filter(rawValue: filter.intValue) else {
      return
    }
    updateComponentState(stateMutation: { $0.nowShowing = filter }, completion: { self.todosList.reloadData() })
  }

  @objc func handleToggle(id: String) {
    properties.model?.toggle(id: id)
  }

  @objc func handleDestroy(id: String) {
    properties.model?.destroy(id: id)
  }

  @objc func handleEdit(id: String) {
    updateComponentState { state in
      state.editing = id
    }
  }

  @objc func handleSave(id: String, text: String) {
    properties.model?.save(id: id, title: text)
    cancel()
  }

  func cancel() {
    updateComponentState { state in
      state.editing = nil
    }
  }

  @objc func handleClearCompleted() {
    properties.model?.clearCompleted()
  }

  func getFilteredTodos() -> [TodoItem] {
    return properties.model?.todos.filter { todoItem in
      switch state.nowShowing {
      case .active:
        return !todoItem.completed
      case .completed:
        return todoItem.completed
      default:
        return true
      }
    } ?? []
  }

  func getActiveTodosCount() -> Int {
    return properties.model?.todos.reduce(0) { accum, todo in
      return todo.completed ? accum : accum + 1
    } ?? 0
  }

  override func render() -> Element {
    var children = [
      renderHeader()
    ]
    let filteredTodos = getFilteredTodos()
    if filteredTodos.count > 0 {
      children.append(renderMain())
    }
    let activeCount = getActiveTodosCount()
    let completedCount = (self.properties.model?.todos.count ?? 0) - activeCount
    if activeCount > 0 || completedCount > 0 {
      children.append(renderFooter(activeCount: activeCount, completedCount: completedCount))
    }

    var properties = BaseProperties()
    properties.layout = self.properties.layout

    return ElementData(ElementType.box, properties, children)
  }

  private func renderHeader() -> Element {
    return render(withLocation: Bundle.main.url(forResource: "Header", withExtension: "xml")!)
  }

  private func renderMain() -> Element {
    return ElementData(ElementType.view(todosList), BaseProperties(["flexGrow": Float(1)]))
  }

  private func renderFooter(activeCount: Int, completedCount: Int) -> Element {
    var properties = FooterProperties()
    properties.count = activeCount
    properties.completedCount = completedCount
    properties.onClearCompleted = #selector(App.handleClearCompleted)
    properties.onUpdateFilter = #selector(App.handleUpdateFilter(filter:))
    properties.nowShowing = state.nowShowing
    return ElementData(ElementType.component(Footer.self), properties)
  }
}
