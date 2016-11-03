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
  var toggleAllEnabled = false
  var isEditingTable = false
  var opacity = Animatable<CGFloat>(0, duration: 1, interpolator: BezierInterpolator(.easeInOutExpo))
  var color = Animatable<UIColor>(.red, duration: 1, delay: 2)
}

func ==(lhs: AppState, rhs: AppState) -> Bool {
  return lhs.nowShowing == rhs.nowShowing && lhs.editing == rhs.editing && lhs.newTodo == rhs.newTodo && lhs.toggleAllEnabled == rhs.toggleAllEnabled && lhs.isEditingTable == rhs.isEditingTable && lhs.opacity == rhs.opacity && lhs.color == rhs.color
}

struct AppProperties: Properties {
  var core = CoreProperties()
  var model: Todos?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)

    model = properties.get("model")
  }

  mutating func merge(_ other: AppProperties) {
    core.merge(other.core)

    merge(&model, other.model)
  }
}

func ==(lhs: AppProperties, rhs: AppProperties) -> Bool {
  return lhs.model == rhs.model && lhs.equals(otherProperties: rhs)
}

class TableManager: NSObject, TableViewDataSource, TableViewDelegate {
  private weak var app: App?

  init(app: App) {
    self.app = app
  }

  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    var properties = TodoProperties()

    properties.todo = app?.getFilteredTodos()[indexPath.row]
    properties.core.layout.width = app?.properties.core.layout.width
    properties.onToggle = #selector(App.handleToggle(id:))
    properties.onSave = #selector(App.handleSave(id:text:))
    properties.onEdit = #selector(App.handleEdit(id:))
    properties.onDestroy = #selector(App.handleDestroy(id:))

    return component(Todo.self, properties)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return app?.getFilteredTodos().count ?? 0
  }

  func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
    guard let todo = app?.properties.model?.todos[indexPath.row] else {
      return
    }
    app?.properties.model?.destroy(id: todo.id)
  }

  func tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
    app?.properties.model?.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
  }
}

class App: Component<AppState, AppProperties, UIView> {
  static let headerTemplateURL = Bundle.main.url(forResource: "Header", withExtension: "xml")!

  private lazy var tableManager: TableManager = {
    return TableManager(app: self)
  }()

  required init(element: Element, children: [Node]?, owner: Node?, context: Context?) {
    super.init(element: element, children: children, owner: owner, context: context)

    self.properties.model?.subscribe { [weak self] in
      // Properties have changed, but have not gotten re-set on this component. Force an update.
      self?.forceUpdate()
    }
  }

  override func getInitialState() -> AppState {
    return AppState()
  }

  @objc func handleEdit() {
    updateState { state in
      state.isEditingTable = !state.isEditingTable
    }
  }

  @objc func handleChange(target: UITextField) {
    updateState { state in
      state.newTodo = target.text ?? ""
    }
  }

  @objc func handleNewTodoSubmit(target: UITextField) {
    properties.model?.addTodo(title: target.text!)
    updateState { state in
      state.newTodo = ""
    }
  }

  @objc func handleToggleAll() {
    updateState( stateMutation: { state in
      state.toggleAllEnabled = !state.toggleAllEnabled
    }, completion: {
      self.properties.model?.toggleAll(checked: self.state.toggleAllEnabled)
    })
  }

  @objc func handleUpdateFilter(filter: NSNumber) {
    guard let filter = Filter(rawValue: filter.intValue) else {
      return
    }
    updateState{ state in
      state.nowShowing = filter
    }
  }

  @objc func handleToggle(id: String) {
    properties.model?.toggle(id: id)
  }

  @objc func handleDestroy(id: String) {
    properties.model?.destroy(id: id)
  }

  @objc func handleEdit(id: String) {
    updateState { state in
      state.editing = id
    }
  }

  @objc func handleSave(id: String, text: String) {
    properties.model?.save(id: id, title: text)
    cancel()
  }

  func cancel() {
    updateState { state in
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

  override func didBuild() {
    animate(state.opacity, to: 1)
    animate(state.color, to: .blue)
  }

  override func render() -> Template {
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

    var properties = DefaultProperties()
    properties.core.layout = self.properties.core.layout
    properties.core.style.opacity = state.opacity.value

    return Template(box(properties, children))
  }

  private func renderHeader() -> Element {
    return render(App.headerTemplateURL).build(with: self)
  }

  private func renderMain() -> Element {
    var properties = TableProperties()
    properties.core.layout.flex = 1
    properties.tableViewDataSource = tableManager
    properties.tableViewDelegate = tableManager
    properties.eventTarget = self
    properties.items = [getFilteredTodos()]
    properties.isEditing = state.isEditingTable
    return table(properties)
  }

  private func renderFooter(activeCount: Int, completedCount: Int) -> Element {
    var properties = FooterProperties()
    properties.count = activeCount
    properties.completedCount = completedCount
    properties.onClearCompleted = #selector(App.handleClearCompleted)
    properties.onUpdateFilter = #selector(App.handleUpdateFilter(filter:))
    properties.nowShowing = state.nowShowing

    return component(Footer.self, properties)
  }
}
