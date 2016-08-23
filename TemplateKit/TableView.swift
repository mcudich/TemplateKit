import UIKit

// This is a sub-set of UITableViewDelegate.
@objc public protocol TableViewDelegate: UIScrollViewDelegate {
  @objc optional func tableView(_ tableView: TableView, nodeNameForHeaderInSection section: Int) -> String?
  @objc optional func tableView(_ tableView: TableView, nodeNameForFooterInSection section: Int) -> String?
  @objc optional func tableView(_ tableView: TableView, propertiesForHeaderInSection section: Int) -> [String: Any]?
  @objc optional func tableView(_ tableView: TableView, propertiesForFooterInSection section: Int) -> [String: Any]?
  @objc optional func tableView(_ tableView: TableView, cacheKeyForHeaderInSection section: Int) -> Int
  @objc optional func tableView(_ tableView: TableView, cacheKeyForFooterInSection section: Int) -> Int

  @objc optional func nodeNameForHeaderInTableView(_ tableView: TableView) -> String?
  @objc optional func nodeNameForFooterInTableView(_ tableView: TableView) -> String?
  @objc optional func propertiesForHeaderInTableView(_ tableView: TableView) -> [String: Any]?
  @objc optional func propertiesForFooterInTableView(_ tableView: TableView) -> [String: Any]?

  @objc optional func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
  @objc optional func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
  @objc optional func tableView(_ tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
  @objc optional func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
  @objc optional func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
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
  func tableView(_ tableView: TableView, nodeNameForRowAtIndexPath indexPath: IndexPath) -> String
  @objc optional func tableView(_ tableView: TableView, propertiesForRowAtIndexPath indexPath: IndexPath) -> [String: Any]?
  // Provide a hash value for the given row to enable component and controller caching.
  @objc optional func tableView(_ tableView: TableView, cacheKeyForRowAtIndexPath indexPath: IndexPath) -> Int

  @objc optional func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
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
    return 0
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
  private var cachedHeaderNode: Node?
  private var cachedFooterNode: Node?
  private var delegateProxy: (DelegateProxyProtocol & UITableViewDelegate)?
  private var dataSourceProxy: (DelegateProxyProtocol & UITableViewDataSource)?
  private lazy var rowNodeCache = [Int: Node]()
  private lazy var headerNodeCache = [Int: Node]()
  private lazy var footerNodeCache = [Int: Node]()

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

  override public func reloadData() {
    super.reloadData()

    // TODO(mcudich): Lay out when table bounds actually change.
    let header = headerNode()
    let footer = footerNode()

    header?.sizeToFit(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
    tableHeaderView = header?.render()
    tableFooterView = footer?.render()
  }

  fileprivate func headerNode() -> Node? {
    guard let nodeName = tableViewDelegate?.nodeNameForHeaderInTableView?(self) else {
      return nil
    }

    let node = cachedHeaderNode ?? nodeProvider.node(withName: nodeName, properties: tableViewDelegate?.propertiesForHeaderInTableView?(self))
    cachedHeaderNode = node

    return node
  }

  fileprivate func footerNode() -> Node? {
    guard let nodeName = tableViewDelegate?.nodeNameForFooterInTableView?(self) else {
      return nil
    }

    let node = cachedFooterNode ?? nodeProvider.node(withName: nodeName, properties: tableViewDelegate?.propertiesForFooterInTableView?(self))
    cachedFooterNode = node

    return node
  }

  fileprivate func node(withIndexPath indexPath: IndexPath) -> Node? {
    guard let tableViewDataSource = tableViewDataSource else {
      return nil
    }

    let cacheKey = tableViewDataSource.tableView(self, cacheKeyForRowAtIndexPath: indexPath)
    if let component = rowNodeCache[cacheKey] {
      return component
    }

    let nodeName = tableViewDataSource.tableView(self, nodeNameForRowAtIndexPath: indexPath)
    let node = nodeProvider.node(withName: nodeName, properties: tableViewDataSource.tableView?(self, propertiesForRowAtIndexPath: indexPath) ?? [:])

    rowNodeCache[cacheKey] = node


    return node
  }

  fileprivate func headerNode(withSection section: Int) -> Node? {
    guard let tableViewDelegate = tableViewDelegate else {
      return nil
    }

    let cacheKey = tableViewDelegate.tableView?(self, cacheKeyForHeaderInSection: section)
    if let cacheKey = cacheKey, let node = headerNodeCache[cacheKey] {
      return node
    }

    guard let nodeName = tableViewDelegate.tableView?(self, nodeNameForHeaderInSection: section) else {
      return nil
    }
    let node = nodeProvider.node(withName: nodeName, properties: tableViewDelegate.tableView?(self, propertiesForHeaderInSection: section))
    if let cacheKey = cacheKey {
      headerNodeCache[cacheKey] = node
    }

    return node
  }

  fileprivate func footerNodeWithSection(_ section: Int) -> Node? {
    guard let tableViewDelegate = tableViewDelegate else {
      return nil
    }

    let cacheKey = tableViewDelegate.tableView?(self, cacheKeyForFooterInSection: section)
    if let cacheKey = cacheKey, let node = footerNodeCache[cacheKey] {
      return node
    }

    guard let nodeName = tableViewDelegate.tableView?(self, nodeNameForFooterInSection: section) else {
      return nil
    }
    let node = nodeProvider.node(withName: nodeName, properties: tableViewDelegate.tableView?(self, propertiesForFooterInSection: section))
    if let cacheKey = cacheKey {
      footerNodeCache[cacheKey] = node
    }

    return node
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
    delegateProxy.registerInterceptable(selector: #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)))
    delegateProxy.registerInterceptable(selector: #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)))
    delegateProxy.registerInterceptable(selector: #selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)))
    delegateProxy.registerInterceptable(selector: #selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)))
    delegateProxy.registerInterceptable(selector: #selector(UITableViewDataSource.tableView(_:cellForRowAt:)))

    return delegateProxy
  }
}

extension TableView {
  func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
    return heightForNode(node(withIndexPath: indexPath))
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return heightForNode(headerNode(withSection: section))
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return heightForNode(footerNodeWithSection(section))
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return headerNode(withSection: section)?.render()
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return footerNodeWithSection(section)?.render()
  }

  func heightForNode(_ node: Node?) -> CGFloat {
    return node?.sizeThatFits(CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)).height ?? 0
  }
}

extension TableView {
  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
    let cell = dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
    if let node = node(withIndexPath: indexPath) {
      cell.node = node
    }
    return cell
  }
}
