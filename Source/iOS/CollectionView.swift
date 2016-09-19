//
//  CollectionView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/12/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol CollectionViewDelegate: UICollectionViewDelegate {}

// A sub-set of UICollectionViewDataSource.
public protocol CollectionViewDataSource: NSObjectProtocol {
  func collectionView(_ collectionView: CollectionView, elementAtIndexPath indexPath: IndexPath) -> Element
  func collectionView(_ collectionView: CollectionView, cacheKeyForItemAtIndexPath indexPath: IndexPath) -> Int
  func numberOfSections(in collectionView: UICollectionView) -> Int
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public extension CollectionViewDataSource {
  func collectionView(_ collectionView: CollectionView, cacheKeyForItemAtIndexPath indexPath: IndexPath) -> Int {
    return IndexPath(item: indexPath.row, section: indexPath.section).hashValue
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    fatalError("Unimplemented")
  }

  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return false
  }

  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
  }
}

class CollectionViewCell: UICollectionViewCell {
  var node: Node? {
    didSet {
      for view in contentView.subviews {
        view.removeFromSuperview()
      }
      if let node = node {
        contentView.addSubview(node.builtView as! UIView)
      }
    }
  }
}

public class CollectionView: UICollectionView, AsyncDataListView {
  public weak var collectionViewDataSource: CollectionViewDataSource? {
    didSet {
      configureCollectionViewDataSource()
    }
  }

  public weak var collectionViewDelegate: CollectionViewDelegate? {
    didSet {
      configureCollectionViewDelegate()
    }
  }

  public override weak var dataSource: UICollectionViewDataSource? {
    set {
      if newValue != nil && newValue !== dataSourceProxy {
        fatalError("dataSource is not available. Use tableViewDatasource instead.")
      }
      super.dataSource = newValue
    }
    get {
      return super.dataSource
    }
  }

  public override weak var delegate: UICollectionViewDelegate? {
    set {
      if newValue != nil && newValue !== delegateProxy {
        fatalError("delegate is not available. Use tableViewDelegate instead.")
      }
      super.delegate = newValue
    }
    get {
      return super.delegate
    }
  }

  lazy var nodeCache = [Int: Node]()
  var context: Context
  lazy var operationQueue = AsyncQueue<AsyncOperation>(maxConcurrentOperationCount: 1)

  private let cellIdentifier = "CollectionViewCell"
  private var dataSourceProxy: (DelegateProxyProtocol & UICollectionViewDataSource)?
  private var delegateProxy: (DelegateProxyProtocol & UICollectionViewDelegate)?

  public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, context: Context) {
    self.context = context

    super.init(frame: frame, collectionViewLayout: layout)

    configureCollectionViewDataSource()
    configureCollectionViewDelegate()

    register(CollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
    operationQueue.enqueueOperation { done in
      super.performBatchUpdates(updates) { completed in
        completion?(completed)
        done()
      }
    }
  }

  public override func insertItems(at indexPaths: [IndexPath]) {
    insertItems(at: indexPaths) {
      super.insertItems(at: indexPaths)
    }
  }

  public override func deleteItems(at indexPaths: [IndexPath]) {
    deleteItems(at: indexPaths) {
      super.deleteItems(at: indexPaths)
    }
  }

  public override func insertSections(_ sections: IndexSet) {
    insertSections(sections) {
      super.insertSections(sections)
    }
  }

  public override func deleteSections(_ sections: IndexSet) {
    deleteSections(sections) {
      super.deleteSections(sections)
    }
  }

  public override func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
    moveItem(at: indexPath, to: newIndexPath) {
      super.moveItem(at: indexPath, to: newIndexPath)
    }
  }

  public override func moveSection(_ section: Int, toSection newSection: Int) {
    moveSection(section, toSection: newSection) {
      super.moveSection(section, toSection: newSection)
    }
  }

  public override func reloadItems(at indexPaths: [IndexPath]) {
    reloadItems(at: indexPaths) {
      super.reloadItems(at: indexPaths)
    }
  }

  public override func reloadSections(_ sections: IndexSet) {
    reloadSections(sections) {
      super.reloadSections(sections)
    }
  }

  public override func reloadData() {
    reloadData {
      super.reloadData()
    }
  }

  func cacheKey(for indexPath: IndexPath) -> Int? {
    return collectionViewDataSource?.collectionView(self, cacheKeyForItemAtIndexPath: indexPath)
  }

  func element(at indexPath: IndexPath) -> Element? {
    return collectionViewDataSource?.collectionView(self, elementAtIndexPath: indexPath)
  }

  func totalNumberOfSections() -> Int {
    return collectionViewDataSource?.numberOfSections(in: self) ?? 1
  }

  func totalNumberOfRows(in section: Int) -> Int? {
    return collectionViewDataSource?.collectionView(self, numberOfItemsInSection: section)
  }

  private func configureCollectionViewDataSource() {
    dataSourceProxy = configureProxy(withTarget: collectionViewDataSource) as? DelegateProxyProtocol & UICollectionViewDataSource
    dataSource = dataSourceProxy
  }

  private func configureCollectionViewDelegate() {
    delegateProxy = configureProxy(withTarget: collectionViewDelegate) as? DelegateProxyProtocol & UICollectionViewDelegate
    delegate = delegateProxy
  }

  private func configureProxy(withTarget target: NSObjectProtocol?) -> DelegateProxyProtocol {
    let delegateProxy = DelegateProxy(target: target, interceptor: self)

    delegateProxy.registerInterceptable(selector: #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:)))
    delegateProxy.registerInterceptable(selector: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:)))
    delegateProxy.registerInterceptable(selector: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:)))

    return delegateProxy
  }

  private func sizeForNode(_ node: Node?) -> CGSize {
    return node?.builtView?.frame.size ?? CGSize.zero
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return nodeCache.count
  }

  // There's some weirdness going on here. The Objective-C runtime requires this method to be named a bit differently
  // so that it will respond to the selector. This will likely need fixing down the road.
  func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
    let cell = dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CollectionViewCell
    if let node = node(at: indexPath) {
      cell.node = node
    }
    return cell
  }

  // Here too.
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    return sizeForNode(node(at: indexPath))
  }
}

extension CollectionView: Updateable {
  public func update() {
    reloadData()
  }
}
