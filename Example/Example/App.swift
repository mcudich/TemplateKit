//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class App: Node {
  var root: Node?
  var renderedView: UIView?
  var properties: [String : Any]
  public var state: Any?
  var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  private var counterValue = 0

  required init(properties: [String : Any]) {
    self.properties = properties
  }

  func build() -> Node {
    return Box(properties: ["width": CGFloat(320), "height": CGFloat(500), "paddingTop": CGFloat(60)]) {
      [
        Counter(properties: ["count": counterValue]),
        Text(properties: ["text": "Randomize", "onTap": randomizeCounter]),
        Image(properties: ["url": URL(string: "https://farm9.staticflickr.com/8520/28696528773_0d0e2f08fb_m_d.jpg"), "width": CGFloat(150), "height": CGFloat(150)])
      ]
    }
  }

  private func randomizeCounter() {
    counterValue = Int(arc4random())
    update()
  }
}
