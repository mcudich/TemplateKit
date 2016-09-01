//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct AppState {
  private(set) var counter = 0

  mutating func increment() {
    counter += 1
  }
}

class App: Node {
  var root: Node?
  var renderedView: UIView?
  var properties: [String : Any]
  public var state: Any? = AppState()
  var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  var appState: AppState {
    set {
      state = newValue
    }
    get {
      return state as! AppState
    }
  }

  required init(properties: [String : Any]) {
    self.properties = properties
  }

  func build(completion: (Node) -> Void) {
    let app = Box(properties: ["width": CGFloat(320), "height": CGFloat(500), "paddingTop": CGFloat(60)]) {
      [Text(properties: ["text": "Increment", "onTap": incrementCounter]),
       Text(properties: ["text": "\(appState.counter)"])]
    }
    completion(app)
  }

  private func incrementCounter() {
    appState.increment()
    update()
  }
}
