//
//  TodosModel.swift
//  Example
//
//  Created by Matias Cudich on 9/20/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

struct TodoItem: Equatable {
  var id: String = UUID().uuidString
  var title: String = ""
  var completed: Bool = false

  init(title: String) {
    self.title = title
  }
}

func ==(lhs: TodoItem, rhs: TodoItem) -> Bool {
  return lhs.id == rhs.id && lhs.title == rhs.title && lhs.completed == rhs.completed
}

typealias ChangeHandler = () -> Void

class Todos: Equatable {
  var todos = [TodoItem]()
  var changes = [ChangeHandler]()

  init() {}

  func subscribe(handler: @escaping ChangeHandler) {
    changes.append(handler)
  }

  func inform() {
    for change in changes {
      change()
    }
  }

  func addTodo(title: String) {
    todos.append(TodoItem(title: title))
    inform()
  }

  func toggleAll(checked: Bool) {
    for var todo in todos {
      todo.completed = checked
    }
    inform()
  }

  func toggle(id: String) {
    for var todo in todos {
      if todo.id == id {
        todo.completed = !todo.completed
        break
      }
    }
    inform()
  }

  func destroy(id: String) {
    todos = todos.filter { todoItem in
      todoItem.id != id
    }
    inform()
  }

  func save(id: String, title: String) {
    for var todo in todos {
      if todo.id == id {
        todo.title = title
        break
      }
    }
    inform()
  }

  func clearCompleted() {
    todos = todos.filter { !$0.completed }
    inform()
  }
}

func ==(lhs: Todos, rhs: Todos) -> Bool {
  return lhs.todos == rhs.todos
}
