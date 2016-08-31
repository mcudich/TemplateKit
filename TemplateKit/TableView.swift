import UIKit

// This is a sub-set of UITableViewDelegate.
@objc public protocol TableViewDelegate: UIScrollViewDelegate {
  @objc optional func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
  @objc optional func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
  @objc optional func tableView(_ tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
  @objc optional func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)

  @objc optional func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat

  @objc optional func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
  @objc optional func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
  @objc optional func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
  @objc optional func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: IndexPath) -> Bool
  @objc optional func tableView(_ tableView: UITableView, didHighlightRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, willSelectRowAtIndexPath indexPath: IndexPath) -> IndexPath?
  @objc optional func tableView(_ tableView: UITableView, willDeselectRowAtIndexPath indexPath: IndexPath) -> IndexPath?
  @objc optional func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, didDeselectRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle
  @objc optional func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: IndexPath) -> String?
  @objc optional func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]?
  @objc optional func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: IndexPath) -> Bool
  @objc optional func tableView(_ tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, didEndEditingRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
  @objc optional func tableView(_ tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: IndexPath) -> Int
  @objc optional func tableView(_ tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: IndexPath) -> Bool
  @objc optional func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: IndexPath, withSender sender: AnyObject?) -> Bool
  @objc optional func tableView(_ tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: IndexPath, withSender sender: AnyObject?)
}

// This is a sub-set of UITableViewDataSource.
@objc public protocol TableViewDataSource: NSObjectProtocol {
  func tableView(_ tableView: TableView, locationForNodeAtIndexPath indexPath: IndexPath) -> URL
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int

  @objc optional func tableView(_ tableView: TableView, propertiesForRowAtIndexPath indexPath: IndexPath) -> [String: Any]?
  // Provide a hash value for the given row to enable component and controller caching.
  @objc optional func tableView(_ tableView: TableView, cacheKeyForRowAtIndexPath indexPath: IndexPath) -> Int

  @objc optional func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
  @objc optional func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
  @objc optional func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
  @objc optional func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool
  @objc optional func tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool
  @objc optional func sectionIndexTitlesForTableView(_ tableView: UITableView) -> [String]?
  @objc optional func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
  @objc optional func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath)
}

extension TableViewDataSource {
  func tableView(_ tableView: TableView, cacheKeyForRowAtIndexPath indexPath: IndexPath) -> Int {
    return NSIndexPath(item: indexPath.item, section: indexPath.section).hashValue
  }
}

class TableViewCell: UITableViewCell {
  var node: Node? {
    didSet {
      for view in contentView.subviews {
        view.removeFromSuperview()
      }
      if let node = node {
        node.sizeToFit(bounds.size)
        contentView.addSubview(node.render())
      }
    }
  }
}

public class TableView: UITableView {
  public weak var tableViewDelegate: TableViewDelegate? {
    didSet {
      configureTableDelegate()
    }
  }
  public weak var tableViewDataSource: TableViewDataSource? {
    didSet {
      configureTableDataSource()
    }
  }

  public override weak var delegate: UITableViewDelegate? {
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

  public override weak var dataSource: UITableViewDataSource? {
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

  fileprivate let cellIdentifier = "TableViewCell"
  fileprivate lazy var rowNodeCache = [Int: Node]()

  private let nodeProvider: NodeProvider
  private lazy var operationQueue = AsyncQueue<AsyncOperation>(maxConcurrentOperationCount: 1)
  private var delegateProxy: (DelegateProxyProtocol & UITableViewDelegate)?
  private var dataSourceProxy: (DelegateProxyProtocol & UITableViewDataSource)?

  public init(nodeProvider: NodeProvider, frame: CGRect, style: UITableViewStyle) {
    self.nodeProvider = nodeProvider

    super.init(frame: frame, style: style)

    configureTableDelegate()
    configureTableDataSource()

    register(TableViewCell.self, forCellReuseIdentifier: cellIdentifier)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate func node(withIndexPath indexPath: IndexPath) -> Node? {
    guard let tableViewDataSource = tableViewDataSource else {
      return nil
    }

    let cacheKey = tableViewDataSource.tableView(self, cacheKeyForRowAtIndexPath: indexPath)
    if let cachedNode = rowNodeCache[cacheKey] {
      return cachedNode
    }

    return nil
  }

  private func configureTableDelegate() {
    delegateProxy = configureProxy(withTarget: tableViewDelegate) as? DelegateProxyProtocol & UITableViewDelegate
    delegate = delegateProxy
  }

  private func configureTableDataSource() {
    dataSourceProxy = configureProxy(withTarget: tableViewDataSource) as? DelegateProxyProtocol & UITableViewDataSource
    dataSource = dataSourceProxy
  }

  private func configureProxy(withTarget target: NSObjectProtocol?) -> DelegateProxyProtocol {
    let delegateProxy = DelegateProxy(target: target, interceptor: self)

    delegateProxy.registerInterceptable(selector: #selector(UITableViewDelegate.tableView(_:heightForRowAt:)))
    delegateProxy.registerInterceptable(selector: #selector(UITableViewDataSource.tableView(_:cellForRowAt:)))
    delegateProxy.registerInterceptable(selector: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:)))

    return delegateProxy
  }

  public override func beginUpdates() {
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.beginUpdates()
        done()
      }
    }
  }

  public override func endUpdates() {
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.endUpdates()
        done()
      }
    }
  }

  public override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
    guard let tableViewDataSource = tableViewDataSource else {
      return
    }

    let insert = {
      super.insertRows(at: indexPaths, with: animation)
    }

    operationQueue.enqueueOperation { done in
      var completedNodes = 0

      for indexPath in indexPaths {
        let cacheKey = tableViewDataSource.tableView(self, cacheKeyForRowAtIndexPath: indexPath)
        let location = tableViewDataSource.tableView(self, locationForNodeAtIndexPath: indexPath)
        let properties = tableViewDataSource.tableView?(self, propertiesForRowAtIndexPath: indexPath) ?? [:]

        self.nodeProvider.node(withLocation: location, properties: properties) { [weak self] result in
          switch result {
          case .success(let node):
            node.sizeToFit(CGSize(width: self?.bounds.width ?? 0, height: CGFloat.greatestFiniteMagnitude))
            self?.rowNodeCache[cacheKey] = node
            completedNodes += 1

            DispatchQueue.main.async {
              UIView.performWithoutAnimation {
                if completedNodes == indexPaths.count {
                  insert()
                  done()
                }
              }
            }
          case .error(let error):
            print(error)
          }
        }
      }
    }
  }

  public override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
    let delete = {
      super.deleteRows(at: indexPaths, with: animation)
    }
    operationQueue.enqueueOperation { done in
      delete()
      done()
    }
  }

  public override func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
    let indexPaths = sections.reduce([]) { previous, section in
      return previous + self.indexPaths(forSection: section)
    }

    insertRows(at: indexPaths, with: animation)
  }

  public override func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
    let delete = {
      super.deleteSections(sections, with: animation)
    }
    operationQueue.enqueueOperation { done in
      delete()
      done()
    }
  }

  public override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
    let move = {
      super.moveRow(at: indexPath, to: newIndexPath)
    }
    operationQueue.enqueueOperation { done in
      move()
      done()
    }
  }

  public override func moveSection(_ section: Int, toSection newSection: Int) {
    let move = {
      super.moveSection(section, toSection: newSection)
    }
    operationQueue.enqueueOperation { done in
      move()
      done()
    }
  }

  public override func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
    let reload = {
      super.reloadRows(at: indexPaths, with: animation)
    }
    operationQueue.enqueueOperation { done in
      reload()
      done()
    }
  }

  public override func reloadSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
    let reload = {
      super.reloadSections(sections, with: animation)
    }
    operationQueue.enqueueOperation { done in
      reload()
      done()
    }
  }

  public override func reloadData() {
    super.reloadData()

    guard let tableViewDataSource = tableViewDataSource else {
      return
    }

    let sectionCount = tableViewDataSource.numberOfSectionsInTableView?(self) ?? 1
    let indexPaths: [IndexPath] = (0..<sectionCount).reduce([]) { previous, section in
      return previous + self.indexPaths(forSection: section)
    }

    insertRows(at: indexPaths, with: .none)
  }

  private func indexPaths(forSection section: Int) -> [IndexPath] {
    guard let tableViewDataSource = tableViewDataSource else {
      return []
    }

    let expectedRowCount = tableViewDataSource.tableView(self, numberOfRowsInSection: section)
    return (0..<expectedRowCount).map { row in
      return IndexPath(row: row, section: section)
    }
  }
}

extension TableView {
  func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
    return heightForNode(node(withIndexPath: indexPath))
  }

  func heightForNode(_ node: Node?) -> CGFloat {
    return node?.view.calculatedFrame?.height ?? 0
  }
}

extension TableView {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rowNodeCache.count
  }

  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
    let cell = dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
    if let node = node(withIndexPath: indexPath) {
      cell.node = node
    }
    return cell
  }
}
