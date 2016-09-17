//
//  AsyncDataListView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/12/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

protocol AsyncDataListView: class {
  var operationQueue: AsyncQueue<AsyncOperation> { get }
  var context: Context { get set }
  var componentCache: [Int: Component] { get set }

  func insertItems(at indexPaths: [IndexPath], completion: @escaping () -> Void)
  func deleteItems(at indexPaths: [IndexPath], completion: @escaping () -> Void)
  func insertSections(_ sections: IndexSet, completion: @escaping () -> Void)
  func deleteSections(_ sections: IndexSet, completion: @escaping () -> Void)
  func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath, completion: @escaping () -> Void)
  func moveSection(_ section: Int, toSection newSection: Int, completion: @escaping () -> Void)
  func reloadItems(at indexPaths: [IndexPath], completion: @escaping () -> Void)
  func reloadSections(_ sections: IndexSet, completion: @escaping () -> Void)
  func reloadData(completion: @escaping () -> Void)

  func cacheKey(for indexPath: IndexPath) -> Int?
  func element(at indexPath: IndexPath) -> Element?
  func component(at indexPath: IndexPath) -> Component?
  func totalNumberOfSections() -> Int
  func totalNumberOfRows(in section: Int) -> Int?
}

extension AsyncDataListView {
  func insertItems(at indexPaths: [IndexPath], completion: @escaping () -> Void) {
    precacheComponents(at: indexPaths)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        completion()
        done()
      }
    }
  }

  func deleteItems(at indexPaths: [IndexPath], completion: @escaping () -> Void) {
    purgeComponents(at: indexPaths)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        completion()
        done()
      }
    }
  }

  func insertSections(_ sections: IndexSet, completion: @escaping () -> Void) {
    precacheComponents(in: sections)
    operationQueue.enqueueOperation { done in
      completion()
      done()
    }
  }

  func deleteSections(_ sections: IndexSet, completion: @escaping () -> Void) {
    purgeComponents(in: sections)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        completion()
        done()
      }
    }
  }

  func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath, completion: @escaping () -> Void) {
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        completion()
        done()
      }
    }
  }

  func moveSection(_ section: Int, toSection newSection: Int, completion: @escaping () -> Void) {
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        completion()
        done()
      }
    }
  }

  func reloadItems(at indexPaths: [IndexPath], completion: @escaping () -> Void) {
    precacheComponents(at: indexPaths)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        completion()
        done()
      }
    }
  }

  func reloadSections(_ sections: IndexSet, completion: @escaping () -> Void) {
    precacheComponents(in: sections)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        completion()
        done()
      }
    }
  }

  func reloadData(completion: @escaping () -> Void) {
    let sectionCount = totalNumberOfSections()
    let indexPaths: [IndexPath] = (0..<sectionCount).reduce([]) { previous, section in
      return previous + self.indexPaths(forSection: section)
    }

    precacheComponents(at: indexPaths)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        completion()
        done()
      }
    }
  }

  func component(at indexPath: IndexPath) -> Component? {
    guard let cacheKey = self.cacheKey(for: indexPath) else {
      return nil
    }
    return componentCache[cacheKey]
  }

  private func indexPaths(forSection section: Int) -> [IndexPath] {
    let expectedRowCount = totalNumberOfRows(in: section) ?? 0
    return (0..<expectedRowCount).map { row in
      return IndexPath(row: row, section: section)
    }
  }

  private func precacheComponents(at indexPaths: [IndexPath]) {
    operationQueue.enqueueOperation { done in
      self.performPrecache(for: indexPaths, done: done)
    }
  }

  private func precacheComponents(in sections: IndexSet) {
    operationQueue.enqueueOperation { done in
      let indexPaths: [IndexPath] = sections.reduce([]) { previous, section in
        return previous + self.indexPaths(forSection: section)
      }
      self.performPrecache(for: indexPaths, done: done)
    }
  }

  private func performPrecache(for indexPaths: [IndexPath], done: @escaping () -> Void) {
    if indexPaths.count == 0 {
      return done()
    }

    var pending = indexPaths.count
    for indexPath in indexPaths {
      guard let cacheKey = self.cacheKey(for: indexPath), let element = self.element(at: indexPath) else {
        continue
      }
      UIKitRenderer.render(element, container: nil, context: context as Context) { [weak self] component in
        self?.componentCache[cacheKey] = component
        pending -= 1
        if pending == 0 {
          done()
        }
      }
    }
  }

  private func purgeComponents(at indexPaths: [IndexPath]) {
    operationQueue.enqueueOperation { done in
      self.performPurge(for: indexPaths, done: done)
    }
  }

  private func purgeComponents(in sections: IndexSet) {
    operationQueue.enqueueOperation { done in
      let indexPaths: [IndexPath] = sections.reduce([]) { previous, section in
        return previous + self.indexPaths(forSection: section)
      }
      self.performPurge(for: indexPaths, done: done)
    }
  }

  private func performPurge(for indexPaths: [IndexPath], done: @escaping () -> Void) {
   if indexPaths.count == 0 {
      return done()
    }

    for indexPath in indexPaths {
      if let cacheKey = self.cacheKey(for: indexPath) {
        self.componentCache.removeValue(forKey: cacheKey)
      }
    }

    done()
  }
}
