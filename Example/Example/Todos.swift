//
//  TodosModel.swift
//  Example
//
//  Created by Matias Cudich on 9/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

struct TodoItem {
  var id: String = UUID().uuidString
  var title: String = ""
  var completed: Bool = false

  init(title: String) {
    self.title = title
  }
}

typealias ChangeHandler = () -> Void

struct Todos {
  var todos: [TodoItem]
  var changes: [ChangeHandler]

  mutating func subscribe(handler: @escaping ChangeHandler) {
    changes.append(handler)
  }

  func inform() {
    for change in changes {
      change()
    }
  }

  mutating func addTodo(title: String) {
    todos.append(TodoItem(title: title))
    inform()
  }

  mutating func toggleAll(checked: Bool) {
    for var todo in todos {
      todo.completed = checked
    }
    inform()
  }

  mutating func toggle(id: String) {
    for var todo in todos {
      if todo.id == id {
        todo.completed = !todo.completed
        break
      }
    }
    inform()
  }

  mutating func destroy(id: String) {
    todos = todos.filter { todoItem in
      todoItem.id != id
    }
    inform()
  }

  mutating func save(id: String, title: String) {
    for var todo in todos {
      if todo.id == id {
        todo.title = title
        break
      }
    }
    inform()
  }

  mutating func clearCompleted() {
    todos = todos.filter { !$0.completed }
    inform()
  }
}
