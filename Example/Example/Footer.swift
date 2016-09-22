//
//  Footer.swift
//  Example
//
//  Created by Matias Cudich on 9/22/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct FooterProperties: ViewProperties {
  var key: String?
  var layout: LayoutProperties?
  var style: StyleProperties?
  var gestures: GestureProperties?

  var count = 0
  var completedCount = 0
  var onClearCompleted: Selector?
  var onUpdateFilter: Selector?
  var nowShowing: Filter?

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    count = properties.get("count") ?? 0
    completedCount = properties.get("completedCount") ?? 0
    onClearCompleted = properties.get("onClearCompleted")
    nowShowing = properties.get("nowShowing")
    onUpdateFilter = properties.get("onUpdateFilter")
  }
}

func ==(lhs: FooterProperties, rhs: FooterProperties) -> Bool {
  return lhs.count == rhs.count && lhs.completedCount == rhs.completedCount && lhs.onClearCompleted == rhs.onClearCompleted && lhs.nowShowing == rhs.nowShowing && lhs.onUpdateFilter == rhs.onUpdateFilter
}

class Footer: CompositeComponent<EmptyState, FooterProperties, UIView> {
  @objc func handleSelectAll() {
    if let onUpdateFilter = properties.onUpdateFilter {
      performSelector(onUpdateFilter, with: Filter.all.rawValue)
    }
  }

  @objc func handleSelectActive() {
    if let onUpdateFilter = properties.onUpdateFilter {
      performSelector(onUpdateFilter, with: Filter.active.rawValue)
    }
  }

  @objc func handleSelectCompleted() {
    if let onUpdateFilter = properties.onUpdateFilter {
      performSelector(onUpdateFilter, with: Filter.completed.rawValue)
    }
  }

  @objc func handleClearCompleted() {
    if let onClearCompleted = properties.onClearCompleted {
      performSelector(onClearCompleted)
    }
  }

  override func render() -> Element {
    let properties: [String: Any] = [
      "todoCountText": "\(self.properties.count) items left",
      "onSelectAll": #selector(Footer.handleSelectAll),
      "onSelectActive": #selector(Footer.handleSelectActive),
      "onSelectCompleted": #selector(Footer.handleSelectCompleted),
      "onClearCompleted": #selector(Footer.handleClearCompleted)
    ]

    return render(withLocation: Bundle.main.url(forResource: "Footer", withExtension: "xml")!, properties: properties)
  }
}
