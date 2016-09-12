//
//  Todo.swift
//  Example
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct TodoState: State {
  var text = "blah"
}

class Todo: CompositeComponent<TodoState> {
  static let location = URL(string: "http://localhost:8000/Todo.xml")!

  override func render() -> Element {
    return render(withLocation: Todo.location, properties: ["todoText": state.text])
  }

  @objc func random() {
    updateState {
      self.state.text = "\(Int(arc4random()))"
      return self.state
    }
  }
}
