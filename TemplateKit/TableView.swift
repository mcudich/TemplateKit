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
  private let nodeProvider: NodeProvider
  private var delegateProxy: (DelegateProxyProtocol & UITableViewDelegate)?
  private var dataSourceProxy: (DelegateProxyProtocol & UITableViewDataSource)?
  fileprivate lazy var rowNodeCache = [Int: Node]()

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

  public override func reloadData() {
    super.reloadData()

    guard let tableViewDataSource = tableViewDataSource else {
      return
    }

    let expectedRowCount = tableViewDataSource.tableView(self, numberOfRowsInSection: 0)
    let indexPaths = (0..<expectedRowCount).map { IndexPath(row: $0, section: 0) }
    var completedNodes = 0
    for indexPath in indexPaths {
      let cacheKey = tableViewDataSource.tableView(self, cacheKeyForRowAtIndexPath: indexPath)
      let location = tableViewDataSource.tableView(self, locationForNodeAtIndexPath: indexPath)
      let properties = tableViewDataSource.tableView?(self, propertiesForRowAtIndexPath: indexPath) ?? [:]

      nodeProvider.node(withLocation: location, properties: properties) { [weak self] result in
        switch result {
        case .success(let node):
          node.sizeToFit(CGSize(width: self?.bounds.width ?? 0, height: CGFloat.greatestFiniteMagnitude))
          self?.rowNodeCache[cacheKey] = node
          completedNodes += 1
          if completedNodes == expectedRowCount {
            DispatchQueue.main.async {
              UIView.setAnimationsEnabled(false)
              self?.insertRows(at: indexPaths, with: .none)
              UIView.setAnimationsEnabled(true)
            }
          }
        case .error(_):
          break
        }
      }
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
