//
//  App.swift
//  SimpleTable
//
//  Created by Matias Cudich on 11/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

import TemplateKit
import CSSLayout

struct AppState: State {
  var items = [CollectionSection]()
}

func ==(lhs: AppState, rhs: AppState) -> Bool {
  return lhs.items.count == rhs.items.count
}

class App: Component<AppState, DefaultProperties, UIView> {

  @objc func addSection() {
    updateState { state in
      state.items.append(CollectionSection(items: ["a"], hashValue: 1))
    }
  }

  @objc func removeSection() {

  }

  override func render() -> Template {
    var properties = DefaultProperties()
    properties.core.layout = self.properties.core.layout

    let tree = box(properties, [
      renderHeader(),
      renderItems()
    ])

    return Template(tree)
  }

  private func renderHeader() -> Element {
    return render(Bundle.main.url(forResource: "Header", withExtension: "xml")!).build(with: self)
  }

  private func renderItems() -> Element {
    var properties = CollectionProperties()
    properties.core.layout.flex = 1
    properties.core.style.backgroundColor = .white
    properties.collectionViewDataSource = self
    properties.items = state.items

    return collection(properties)
  }

  override func getInitialState() -> AppState {
    var state = AppState()
    state.items = [CollectionSection(items: ["1"], hashValue: 0)]
    return state
  }
}

extension App: CollectionViewDataSource {
  func collectionView(_ collectionView: CollectionView, elementAtIndexPath indexPath: IndexPath) -> Element {
    var properties = ItemProperties()
    properties.item = state.items[indexPath.section].items[indexPath.row] as? String
    properties.core.layout.width = self.properties.core.layout.width
    return component(Item.self, properties)
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return state.items[section].items.count
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return state.items.count
  }
}
