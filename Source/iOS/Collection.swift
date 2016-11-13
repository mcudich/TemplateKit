//
//  Collection.swift
//  TemplateKit
//
//  Created by Matias Cudich on 11/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

public struct CollectionSection: Hashable {
  public let items: [AnyHashable]
  public var hashValue: Int

  public init(items: [AnyHashable], hashValue: Int) {
    self.items = items
    self.hashValue = hashValue
  }
}

public func ==(lhs: CollectionSection, rhs: CollectionSection) -> Bool {
  return false
}

public struct CollectionProperties: Properties {
  public var core = CoreProperties()

  weak public var collectionViewDelegate: CollectionViewDelegate?
  weak public var collectionViewDataSource: CollectionViewDataSource?
  weak public var eventTarget: Node?

  public var layout: UICollectionViewLayout?

  // This is used to know when the underlying table view rows should be inserted, deleted or moved.
  // This 2-d array should follow the list of sections and rows provided by the data source. When
  // this value changes, the table is automatically updated for you using the minimal set of
  // operations required.
  public var items: [CollectionSection]?

  public var onEndReached: Selector?
  public var onEndReachedThreshold: CGFloat?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)

    collectionViewDelegate = properties["collectionViewDelegate"] as? CollectionViewDelegate
    collectionViewDataSource = properties["collectionViewDataSource"] as? CollectionViewDataSource
    layout = properties["layout"] as? UICollectionViewLayout
    eventTarget = properties["eventTarget"] as? Node
    items = properties["items"] as? [CollectionSection]
    onEndReached = properties.cast("onEndReached")
    onEndReachedThreshold = properties.cast("onEndReachedThreshold")
  }

  public mutating func merge(_ other: CollectionProperties) {
    core.merge(other.core)

    merge(&collectionViewDelegate, other.collectionViewDelegate)
    merge(&collectionViewDataSource, other.collectionViewDataSource)
    merge(&layout, other.layout)
    merge(&eventTarget, other.eventTarget)
    merge(&items, other.items)
    merge(&onEndReached, other.onEndReached)
    merge(&onEndReachedThreshold, other.onEndReachedThreshold)
  }
}

public func ==(lhs: CollectionProperties, rhs: CollectionProperties) -> Bool {
  return lhs.collectionViewDelegate === rhs.collectionViewDelegate && lhs.collectionViewDataSource === rhs.collectionViewDataSource &&  lhs.layout === rhs.layout && lhs.eventTarget === rhs.eventTarget && lhs.items == rhs.items && lhs.onEndReached == rhs.onEndReached && lhs.onEndReachedThreshold == rhs.onEndReachedThreshold && lhs.equals(otherProperties: rhs)
}

public class Collection: PropertyNode {
  public weak var parent: Node?
  public weak var owner: Node?
  public var context: Context?

  public var properties: CollectionProperties {
    didSet {
      if let oldItems = oldValue.items, let newItems = properties.items {
        precondition(newItems.count > 0, "Items must contain at least one section.")
        updateRows(old: oldItems, new: newItems)
      }
    }
  }
  public var children: [Node]?
  public var element: ElementData<CollectionProperties>
  public var cssNode: CSSNode?

  lazy public var view: View = {
    let layout = self.properties.layout ?? UICollectionViewFlowLayout()
    return CollectionView(frame: CGRect.zero, collectionViewLayout: layout, context: self.getContext())
  }()

  private var collectionView: CollectionView? {
    return view as? CollectionView
  }

  private lazy var scrollProxy: ScrollProxy = {
    let proxy = ScrollProxy()
    proxy.delegate = self
    return proxy
  }()

  private var delegateProxy: DelegateProxy?
  fileprivate var lastReportedEndLength: CGFloat = 0

  public required init(element: ElementData<CollectionProperties>, children: [Node]? = nil, owner: Node? = nil, context: Context? = nil) {
    self.element = element
    self.properties = element.properties
    self.children = children
    self.owner = owner
    self.context = context

    if let items = properties.items {
      precondition(items.count > 0, "Items must contain at least one section.")
    }

    updateParent()
  }

  public func build() -> View {
    if delegateProxy == nil || delegateProxy?.target !== properties.collectionViewDelegate {
      delegateProxy = DelegateProxy(target: properties.collectionViewDelegate, interceptor: scrollProxy)
      delegateProxy?.registerInterceptable(selector: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:)))
    }

    if collectionView?.collectionViewDelegate !== delegateProxy {
      collectionView?.collectionViewDelegate = delegateProxy as? CollectionViewDelegate
    }
    if collectionView?.collectionViewDataSource !== properties.collectionViewDataSource {
      collectionView?.collectionViewDataSource = properties.collectionViewDataSource
    }

    collectionView?.eventTarget = properties.eventTarget
    collectionView?.backgroundColor = .clear

    return view
  }

  private func updateRows(old: [CollectionSection], new: [CollectionSection]) {
    let updates = {
      let sectionResult = diff(old, new)
      var insertedSections = Set<Int>()
      var deletedSections = Set<Int>()
      for step in sectionResult {
        switch step {
        case .delete(let index):
          deletedSections.insert(index)
          self.collectionView?.deleteSections(IndexSet(integer: index))
        case .insert(let index):
          insertedSections.insert(index)
          self.collectionView?.insertSections(IndexSet(integer: index))
        case .update(let index):
          // Updates are handled below.
          break
        default:
          break
        }
      }

      var deletions = [IndexPath]()
      var insertions = [IndexPath]()
      var updates = [IndexPath]()

      for (sectionIndex, section) in new.enumerated() {
        let oldItems = old.count > sectionIndex ? old[sectionIndex].items : []
        let result = diff(oldItems, section.items)
        for step in result {
          switch step {
          case .delete(let index) where !deletedSections.contains(sectionIndex):
            deletions.append(IndexPath(row: index, section: sectionIndex))
          case .insert(let index) where !insertedSections.contains(sectionIndex):
            insertions.append(IndexPath(row: index, section: sectionIndex))
          case .update(let index):
            updates.append(IndexPath(row: index, section: sectionIndex))
          default:
            break
          }
        }
      }

      self.collectionView?.deleteItems(at: deletions)
      self.collectionView?.insertItems(at: insertions)
      self.collectionView?.reloadItems(at: updates)
    }

    collectionView?.performBatchUpdates(updates)
  }
}

extension Collection: ScrollProxyDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    properties.collectionViewDelegate?.scrollViewDidScroll?(scrollView)

    let threshold = properties.onEndReachedThreshold ?? 0
    if let onEndReached = properties.onEndReached, scrollView.contentSize.height != lastReportedEndLength, distanceFromEnd(of: scrollView) < threshold, let owner = owner {
      lastReportedEndLength = scrollView.contentSize.height
      _ = (owner as AnyObject).perform(onEndReached)
    }
  }

  private func distanceFromEnd(of scrollView: UIScrollView) -> CGFloat {
    return scrollView.contentSize.height - (scrollView.bounds.height + scrollView.contentOffset.y)
  }
}
