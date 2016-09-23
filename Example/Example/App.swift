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

struct HeaderProperties: ViewProperties {
  var key: String?
  var layout: LayoutProperties?
  var style: StyleProperties?
  var gestures: GestureProperties?

  var text: String?
  var onChange: Selector?
  var onSubmit: Selector?
  var onToggleAll: Selector?

  public init(_ properties: [String: Any]) {
    applyProperties(properties)

    text = properties.cast("text")
    onChange = properties.cast("onChange")
    onSubmit = properties.cast("onSubmit")
    onToggleAll = properties.cast("onToggleAll")
  }
}

func ==(lhs: HeaderProperties, rhs: HeaderProperties) -> Bool {
  return lhs.text == rhs.text && lhs.onChange == rhs.onChange && lhs.onSubmit == rhs.onSubmit && lhs.onToggleAll == rhs.onToggleAll
}

extension App: TableViewDataSource {
  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    let properties: [String: Any] = [
      "todo": getFilteredTodos()[indexPath.row],
      "width": Float(320),
      "onToggle": #selector(App.handleToggle(id:)),
      "onSave": #selector(App.handleSave(id:text:)),
      "onEdit": #selector(App.handleEdit(id:)),
      "onDestroy": #selector(App.handleDestroy(id:))
    ]
    return ElementData(ElementType.component(Todo.self), TodoProperties(properties))
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
    let completedCount = (properties.model?.todos.count ?? 0) - activeCount
    if activeCount > 0 || completedCount > 0 {
      children.append(renderFooter(activeCount: activeCount, completedCount: completedCount))
    }

    return ElementData(ElementType.box, BaseProperties(["width": properties.layout?.size?.width, "height": properties.layout?.size?.height]), children)
  }

  private func renderHeader() -> Element {
    let properties: [String: Any] = [
      "text": state.newTodo,
      "onChange": #selector(App.handleChange(target:)),
      "onSubmit": #selector(App.handleNewTodoSubmit(target:)),
      "onToggleAll": #selector(App.handleToggleAll(target:))
    ]
    return render(withLocation: Bundle.main.url(forResource: "Header", withExtension: "xml")!, properties: HeaderProperties(properties))
  }

  private func renderMain() -> Element {
    return ElementData(ElementType.view(todosList), BaseProperties(["flexGrow": Float(1)]))
  }

  private func renderFooter(activeCount: Int, completedCount: Int) -> Element {
    let properties: [String: Any] = [
      "count": activeCount,
      "completedCount": completedCount,
      "onClearCompleted": #selector(App.handleClearCompleted),
      "onUpdateFilter": #selector(App.handleUpdateFilter(filter:)),
      "nowShowing": state.nowShowing
    ]
    return ElementData(ElementType.component(Footer.self), FooterProperties(properties))
  }
}
