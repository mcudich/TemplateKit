//
//  RemoteApp.swift
//  Example
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct RemoteAppState: State, Equatable {
  var counter = 0
}

func ==(lhs: RemoteAppState, rhs: RemoteAppState) -> Bool {
  return lhs.counter == rhs.counter
}

class RemoteApp: CompositeComponent<RemoteAppState, BaseProperties, UIView> {
  static let location = URL(string: "http://localhost:8000/App.xml")!

  override func render() -> Element {
    return render(withLocation: RemoteApp.location, properties: ["width": Float(320), "height": Float(568), "count": "\(state.counter)", "incrementCounter": #selector(RemoteApp.incrementCounter)])
  }

  @objc func incrementCounter() {
    updateComponentState { state in
      state.counter += 1
    }
  }
}
