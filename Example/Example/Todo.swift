//
//  TodoItem.swift
//  Example
//
//  Created by Matias Cudich on 9/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct TodoItemState: State {
  var editText = ""

  init() {}

  init(editText: String) {
    self.editText = editText
  }
}

func ==(lhs: TodoItemState, rhs: TodoItemState) -> Bool {
  return false
}

struct TodoItemProperties: ViewProperties {
  var key: String?
  var layout: LayoutProperties?
  var style: StyleProperties?
  var gestures: GestureProperties?

  var todo: TodoItem?
  var editing: Bool?
  var onToggle: Selector?
  var onDestroy: Selector?
  var onEdit: Selector?
  var onSave: Selector?
  var onCancel: Selector?

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    todo = properties.get("todo")
    editing = properties.get("editing")
    onToggle = properties.get("onToggle")
    onDestroy = properties.get("onDestroy")
    onEdit = properties.get("onEdit")
    onSave = properties.get("onSave")
    onCancel = properties.get("onCancel")
  }
}

func ==(lhs: TodoItemProperties, rhs: TodoItemProperties) -> Bool {
  return false
}

class Todo: CompositeComponent<TodoItemState, TodoItemProperties, UIView> {
  func handleSubmit() {

  }

  func handleEdit() {

  }

  func handleChange() {

  }

  @objc func handleToggle() {
    if let onToggle = properties.onToggle {
      let _ = (owner! as AnyObject).perform(onToggle, with: properties.todo!.id)
    }
  }

  override func render() -> Element {
    let properties: [String: Any] = [
      "buttonBackgroundColor": (self.properties.todo?.completed ?? false) ? UIColor.green : UIColor.red,
      "onToggle": #selector(Todo.handleToggle)
    ]

    return render(withLocation: Bundle.main.url(forResource: "Todo", withExtension: "xml")!, properties: properties)
  }

  override func getInitialState() -> TodoItemState {
    return TodoItemState(editText: properties.todo?.title ?? "")
  }
}
