//
//  Table.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/29/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

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
  public var items: [[AnyHashable]]?

  public var onEndReached: Selector?
  public var onEndReachedThreshold: CGFloat?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)

    tableViewDelegate = properties["tableViewDelegate"] as? TableViewDelegate
    tableViewDataSource = properties["tableViewDataSource"] as? TableViewDataSource
    eventTarget = properties["eventTarget"] as? Node
    isEditing = properties.cast("isEditing")
    items = properties["items"] as? [[AnyHashable]]
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

protocol ScrollProxyDelegate: class {
  func scrollViewDidScroll(_ scrollView: UIScrollView)
}

public class ScrollProxy: NSObject {
  weak var delegate: ScrollProxyDelegate?

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    delegate?.scrollViewDidScroll(scrollView)
  }
}

public class Table: PropertyNode {
  public weak var parent: Node?
  public weak var owner: Node?
  public var context: Context?

  public var properties: TableProperties {
    didSet {
      if let oldItems = oldValue.items, let newItems = properties.items, oldItems != newItems {
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

    updateParent()
  }

  public func build() -> View {
    if delegateProxy == nil || delegateProxy?.target !== properties.tableViewDelegate {
      delegateProxy = DelegateProxy(target: properties.tableViewDelegate, interceptor: scrollProxy)
      delegateProxy?.registerInterceptable(selector: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:)))
    }

    tableView?.tableViewDelegate = delegateProxy as? TableViewDelegate
    if tableView?.tableViewDataSource !== properties.tableViewDataSource {
      tableView?.tableViewDataSource = properties.tableViewDataSource
    }

    tableView?.eventTarget = properties.eventTarget
    if tableView?.isEditing != properties.isEditing {
      tableView?.setEditing(properties.isEditing ?? false, animated: true)
    }

    return view
  }

  private func updateRows(old: [[AnyHashable]], new: [[AnyHashable]]) {
    tableView?.beginUpdates()

    var deletions = [IndexPath]()
    var insertions = [IndexPath]()
    var updates = [IndexPath]()

    for (sectionIndex, section) in new.enumerated() {
      let result = diff(old[sectionIndex], section)
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
