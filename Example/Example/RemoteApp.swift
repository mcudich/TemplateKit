//
//  RemoteApp.swift
//  Example
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class RemoteApp: Node {
  static let location = Bundle.main.url(forResource: "App", withExtension: "xml")!
  public weak var owner: Node?
  public var currentInstance: BaseNode?
  public var currentElement: Element?
  public var properties: [String : Any]
  public var state: Any? = State()

  fileprivate var todoCount = 0

  struct State {
    var counter = 0
    var showCounter = false
    var flipped = false
  }

  private var appState: State {
    get {
      return state as! State
    }
    set {
      state = newValue
    }
  }

  required init(properties: [String : Any], owner: Node?) {
    self.properties = properties
    self.owner = owner
  }

  func render() -> Element {
    return try! TemplateService.shared.element(withLocation: RemoteApp.location, properties: ["width": CGFloat(320), "height": CGFloat(568), "count": "\(appState.counter)", "incrementCounter": #selector(RemoteApp.incrementCounter)])
  }

  @objc func incrementCounter() {
    updateState {
      appState.counter += 1
      return appState
    }
  }
}
