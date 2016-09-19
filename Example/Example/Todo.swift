//
//  Todo.swift
//  Example
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct TodoState: State, Equatable {
  var text = "blah"
}

func ==(lhs: TodoState, rhs: TodoState) -> Bool {
  return lhs.text == rhs.text
}

class Todo: CompositeComponent<TodoState, UIView> {
  static let location = URL(string: "http://localhost:8000/Todo.xml")!

  override func render() -> Element {
    return render(withLocation: Todo.location, properties: ["todoText": state.text, "width": get("width") ?? Float(0)])
  }

  @objc func random() {
    updateComponentState { state in
      state.text = "\(Int(arc4random()))"
    }
  }
}
