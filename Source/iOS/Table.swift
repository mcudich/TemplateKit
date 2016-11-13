//
//  Table.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/29/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

public struct TableSection: Hashable {
  public let items: [AnyHashable]
  public var hashValue: Int

  public init(items: [AnyHashable], hashValue: Int) {
    self.items = items
    self.hashValue = hashValue
  }
}

public func ==(lhs: TableSection, rhs: TableSection) -> Bool {
  return false
}

public struct TableProperties: Properties {
  public var core = CoreProperties()

  weak public var tableViewDelegate: TableViewDelegate?
  weak public var tableViewDataSource: TableViewDataSource?
  weak public var eventTarget: Node?

  public var isEditing: Bool?

  // This is used to know when the underlying table view rows should be inserted, deleted or moved.
  // This 2-d array should follow the list of sections and rows provided by the data source. When
  // this value changes, the table is automatically updated for you using the minimal set of
  // operations required.
  public var items: [TableSection]?

  public var onEndReached: Selector?
  public var onEndReachedThreshold: CGFloat?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)

    tableViewDelegate = properties["tableViewDelegate"] as? TableViewDelegate
    tableViewDataSource = properties["tableViewDataSource"] as? TableViewDataSource
    eventTarget = properties["eventTarget"] as? Node
    isEditing = properties.cast("isEditing")
    items = properties["items"] as? [TableSection]
    onEndReached = properties.cast("onEndReached")
    onEndReachedThreshold = properties.cast("onEndReachedThreshold")
  }

  public mutating func merge(_ other: TableProperties) {
    core.merge(other.core)

    merge(&tableViewDelegate, other.tableViewDelegate)
    merge(&tableViewDataSource, other.tableViewDataSource)
    merge(&eventTarget, other.eventTarget)
    merge(&isEditing, other.isEditing)
    merge(&items, other.items)
    merge(&onEndReached, other.onEndReached)
    merge(&onEndReachedThreshold, other.onEndReachedThreshold)
  }
}

public func ==(lhs: TableProperties, rhs: TableProperties) -> Bool {
  return lhs.tableViewDelegate === rhs.tableViewDelegate && lhs.tableViewDataSource === rhs.tableViewDataSource && lhs.eventTarget === rhs.eventTarget && lhs.isEditing == rhs.isEditing && lhs.items == rhs.items && lhs.onEndReached == rhs.onEndReached && lhs.onEndReachedThreshold == rhs.onEndReachedThreshold && lhs.equals(otherProperties: rhs)
}

public class Table: PropertyNode {
  public weak var parent: Node?
  public weak var owner: Node?
  public var context: Context?

  public var properties: TableProperties {
    didSet {
      if let oldItems = oldValue.items, let newItems = properties.items {
        precondition(newItems.count > 0, "Items must contain at least one section.")
        updateRows(old: oldItems, new: newItems)
      }
    }
  }
  public var children: [Node]?
  public var element: ElementData<TableProperties>
  public var cssNode: CSSNode?

  lazy public var view: View = {
    return TableView(frame: CGRect.zero, style: .plain, context: self.getContext())
  }()

  private var tableView: TableView? {
    return view as? TableView
  }

  private lazy var scrollProxy: ScrollProxy = {
    let proxy = ScrollProxy()
    proxy.delegate = self
    return proxy
  }()

  private var delegateProxy: DelegateProxy?
  fileprivate var lastReportedEndLength: CGFloat = 0

  public required init(element: ElementData<TableProperties>, children: [Node]? = nil, owner: Node? = nil, context: Context? = nil) {
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
    if delegateProxy == nil || delegateProxy?.target !== properties.tableViewDelegate {
      delegateProxy = DelegateProxy(target: properties.tableViewDelegate, interceptor: scrollProxy)
      delegateProxy?.registerInterceptable(selector: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:)))
    }

    if tableView?.tableViewDelegate !== delegateProxy {
      tableView?.tableViewDelegate = delegateProxy as? TableViewDelegate
    }
    if tableView?.tableViewDataSource !== properties.tableViewDataSource {
      tableView?.tableViewDataSource = properties.tableViewDataSource
    }

    tableView?.eventTarget = properties.eventTarget
    if tableView?.isEditing != properties.isEditing {
      tableView?.setEditing(properties.isEditing ?? false, animated: true)
    }

    return view
  }

  private func updateRows(old: [TableSection], new: [TableSection]) {
    tableView?.beginUpdates()

    let sectionResult = diff(old, new)
    for step in sectionResult {
      switch step {
      case .delete(let index):
        tableView?.deleteSections(IndexSet(integer: index), with: .none)
      case .insert(let index):
        tableView?.insertSections(IndexSet(integer: index), with: .none)
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
        case .delete(let index):
          deletions.append(IndexPath(row: index, section: sectionIndex))
        case .insert(let index):
          insertions.append(IndexPath(row: index, section: sectionIndex))
        case .update(let index):
          updates.append(IndexPath(row: index, section: sectionIndex))
        default:
          break
        }
      }
    }

    tableView?.deleteRows(at: deletions, with: .none)
    tableView?.insertRows(at: insertions, with: .none)
    tableView?.reloadRows(at: updates, with: .none)

    tableView?.endUpdates()
  }
}

extension Table: ScrollProxyDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    properties.tableViewDelegate?.scrollViewDidScroll?(scrollView)

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
