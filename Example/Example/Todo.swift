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
  var editText: String?
}

func ==(lhs: TodoItemState, rhs: TodoItemState) -> Bool {
  return lhs.editText == rhs.editText
}

struct TodoItemProperties: ViewProperties {
  var key: String?
  var layout: LayoutProperties?
  var style: StyleProperties?
  var gestures: GestureProperties?

  var todo: TodoItem?
  var editing = false
  var onToggle: Selector?
  var onDestroy: Selector?
  var onEdit: Selector?
  var onSave: Selector?
  var onCancel: Selector?

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    todo = properties.get("todo")
    editing = properties.get("editing") ?? false
    onToggle = properties.get("onToggle")
    onDestroy = properties.get("onDestroy")
    onEdit = properties.get("onEdit")
    onSave = properties.get("onSave")
    onCancel = properties.get("onCancel")
  }
}

func ==(lhs: TodoItemProperties, rhs: TodoItemProperties) -> Bool {
  return lhs.todo == rhs.todo && lhs.editing == rhs.editing && lhs.onToggle == rhs.onToggle && lhs.onDestroy == rhs.onDestroy && lhs.onEdit == rhs.onEdit && lhs.onSave == rhs.onSave && lhs.onCancel == rhs.onCancel
}

class Todo: CompositeComponent<TodoItemState, TodoItemProperties, UIView> {
  @objc func handleSubmit(target: UITextField) {
    guard let todo = properties.todo else { return }

    if let onSave = properties.onSave, let text = target.text, !text.isEmpty {
      performSelector(onSave, with: todo.id, with: text)
      updateComponentState { state in
        state.editText = nil
      }
    } else if let onDestroy = properties.onDestroy {
      performSelector(onDestroy, with: todo.id)
    }
  }

  @objc func handleEdit() {
    guard let onEdit = properties.onEdit, let todo = properties.todo else { return }

    performSelector(onEdit, with: todo.id)
    updateComponentState { state in
      state.editText = todo.title
    }
  }

  @objc func handleChange(target: UITextField) {
    if self.properties.editing {
      updateComponentState { state in
        state.editText = target.text
      }
    }
  }

  @objc func handleToggle() {
    if let onToggle = properties.onToggle {
      performSelector(onToggle, with: properties.todo?.id)
    }
  }

  @objc func handleDestroy() {
    if let onDestroy = properties.onDestroy {
      performSelector(onDestroy, with: properties.todo?.id)
    }
  }

  override func render() -> Element {
    let properties: [String: Any] = [
      "buttonBackgroundColor": (self.properties.todo?.completed ?? false) ? UIColor.green : UIColor.red,
      "onToggle": #selector(Todo.handleToggle),
      "text": state.editText ?? self.properties.todo?.title,
      "onChange": #selector(Todo.handleChange(target:)),
      "onSubmit": #selector(Todo.handleSubmit(target:)),
      "onBlur": #selector(Todo.handleSubmit(target:)),
      "width": self.properties.layout?.size?.width,
      "enabled": state.editText != nil,
      "focused": state.editText != nil,
      "onEdit": #selector(Todo.handleEdit),
      "onDestroy": #selector(Todo.handleDestroy)
    ]

    return render(withLocation: Bundle.main.url(forResource: "Todo", withExtension: "xml")!, properties: properties)
  }
}
