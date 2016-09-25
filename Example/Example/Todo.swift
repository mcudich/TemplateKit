//
//  TodoItem.swift
//  Example
//
//  Created by Matias Cudich on 9/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct TodoState: State {
  var editText: String?
}

func ==(lhs: TodoState, rhs: TodoState) -> Bool {
  return lhs.editText == rhs.editText
}

struct TodoProperties: ViewProperties {
  var key: String?
  var layout = LayoutProperties()
  var style = StyleProperties()
  var gestures = GestureProperties()

  var todo: TodoItem?
  var editing = false
  var onToggle: Selector?
  var onDestroy: Selector?
  var onEdit: Selector?
  var onSave: Selector?
  var onCancel: Selector?

  public init() {}

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    todo = properties.get("todo")
    editing = properties.cast("editing") ?? false
    onToggle = properties.cast("onToggle")
    onDestroy = properties.cast("onDestroy")
    onEdit = properties.cast("onEdit(")
    onSave = properties.cast("onSave")
    onCancel = properties.cast("onCancel")
  }
}

func ==(lhs: TodoProperties, rhs: TodoProperties) -> Bool {
  return lhs.todo == rhs.todo && lhs.editing == rhs.editing && lhs.onToggle == rhs.onToggle && lhs.onDestroy == rhs.onDestroy && lhs.onEdit == rhs.onEdit && lhs.onSave == rhs.onSave && lhs.onCancel == rhs.onCancel
}

struct TodoTemplateProperties: ViewProperties {
  var key: String?
  var layout = LayoutProperties()
  var style = StyleProperties()
  var gestures = GestureProperties()

  var buttonBackgroundColor: UIColor?
  var onToggle: Selector?
  var text: String?
  var onChange: Selector?
  var onSubmit: Selector?
  var onBlur: Selector?
  var onEdit: Selector?
  var onDestroy: Selector?
  var enabled: Bool?
  var focused: Bool?

  public init() {}
  public init(_ properties: [String: Any]) {}
}

func ==(lhs: TodoTemplateProperties, rhs: TodoTemplateProperties) -> Bool {
  return false
}

class Todo: CompositeComponent<TodoState, TodoProperties, UIView> {
  var buttonBackgroundColor: UIColor?
  var text: String?
  var enabled: Bool?

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
    buttonBackgroundColor = (self.properties.todo?.completed ?? false) ? UIColor.green : UIColor.red
    enabled = state.editText != nil
    text = state.editText ?? self.properties.todo?.title
    return render(withLocation: Bundle.main.url(forResource: "Todo", withExtension: "xml")!)
  }
}
