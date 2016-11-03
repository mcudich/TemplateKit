//
//  Footer.swift
//  Example
//
//  Created by Matias Cudich on 9/22/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

struct FooterProperties: Properties {
  var core = CoreProperties()

  var count: Int?
  var completedCount: Int?
  var onClearCompleted: Selector?
  var onUpdateFilter: Selector?
  var nowShowing: Filter?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)

    count = properties.cast("count") ?? 0
    completedCount = properties.cast("completedCount") ?? 0
    onClearCompleted = properties.cast("onClearCompleted")
    nowShowing = properties.get("nowShowing")
    onUpdateFilter = properties.cast("onUpdateFilter")
  }

  mutating func merge(_ other: FooterProperties) {
    core.merge(other.core)

    merge(&count, other.count)
    merge(&completedCount, other.completedCount)
    merge(&onClearCompleted, other.onClearCompleted)
    merge(&nowShowing, other.nowShowing)
    merge(&onUpdateFilter, other.onUpdateFilter)
  }
}

func ==(lhs: FooterProperties, rhs: FooterProperties) -> Bool {
  return lhs.count == rhs.count && lhs.completedCount == rhs.completedCount && lhs.onClearCompleted == rhs.onClearCompleted && lhs.nowShowing == rhs.nowShowing && lhs.onUpdateFilter == rhs.onUpdateFilter
}

class Footer: Component<EmptyState, FooterProperties, UIView> {
  static let templateURL = Bundle.main.url(forResource: "Footer", withExtension: "xml")!

  var count: String?
  var allSelected = false
  var activeSelected = false
  var completedSelected = false

  @objc func handleSelectAll() {
    performSelector(properties.onUpdateFilter, with: Filter.all.rawValue)
  }

  @objc func handleSelectActive() {
    performSelector(properties.onUpdateFilter, with: Filter.active.rawValue)
  }

  @objc func handleSelectCompleted() {
    performSelector(properties.onUpdateFilter, with: Filter.completed.rawValue)
  }

  @objc func handleClearCompleted() {
    performSelector(properties.onClearCompleted)
  }

  override func render() -> Template {
    count = "\(properties.completedCount ?? 0) items completed"
    allSelected = properties.nowShowing == .all
    activeSelected = properties.nowShowing == .active
    completedSelected = properties.nowShowing == .completed

    return render(Footer.templateURL)
  }
}
