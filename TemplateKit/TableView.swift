import UIKit
import Proxy

public protocol TableViewItemController {
  var node: Node? { set get }
  var model: Model? { set get }
}

public protocol TableViewTemplateDelegate: class {
  func tableView(tableView: UITableView, nodeNameForHeaderInSection section: Int) -> String?
  func tableView(tableView: UITableView, nodeNameForFooterInSection section: Int) -> String?
  func tableView(tableView: UITableView, modelForHeaderInSection section: Int) -> Model?
  func tableView(tableView: UITableView, modelForFooterInSection section: Int) -> Model?
  func tableView(tableView: UITableView, controllerForHeaderInSection section: Int) -> TableViewItemController?
  func tableView(tableView: UITableView, controllerForFooterInSection section: Int) -> TableViewItemController?
  func tableView(tableView: UITableView, cacheKeyForHeaderInSection section: Int) -> Int?
  func tableView(tableView: UITableView, cacheKeyForFooterInSection section: Int) -> Int?

  func nodeNameForHeaderInTableView(tableView: UITableView) -> String?
  func nodeNameForFooterInTableView(tableView: UITableView) -> String?
  func modelForHeaderInTableView(tableView: UITableView) -> Model?
  func modelForFooterInTableView(tableView: UITableView) -> Model?
  func controllerForHeaderInTableView(tableView: UITableView) -> TableViewItemController?
  func controllerForFooterInTableView(tableView: UITableView) -> TableViewItemController?
}

public protocol TableViewTemplateDataSource: class {
  func tableView(tableView: UITableView, nodeNameForRowAtIndexPath indexPath: NSIndexPath) -> String
  func tableView(tableView: UITableView, modelForRowAtIndexPath indexPath: NSIndexPath) -> Model?
  func tableView(tableView: UITableView, controllerForRowAtIndexPath indexPath: NSIndexPath) -> TableViewItemController?
  // Provide a hash value for the given row to enable component and controller caching.
  func tableView(tableView: UITableView, cacheKeyForRowAtIndexPath indexPath: NSIndexPath) -> Int?
}

extension TableViewTemplateDataSource {
  public func tableView(tableView: UITableView, modelForRowAtIndexPath indexPath: NSIndexPath) -> Model? {
    return nil
  }

  public func tableView(tableView: UITableView, controllerForRowAtIndexPath indexPath: NSIndexPath) -> TableViewItemController? {
    return nil
  }

  public func tableView(tableView: UITableView, cacheKeyForRowAtIndexPath indexPath: NSIndexPath) -> Int? {
    return NSIndexPath(forRow: indexPath.row, inSection: indexPath.section).hashValue
  }
}

// This is a sub-set of UITableViewDelegate.
@objc public protocol TableViewDelegate: UIScrollViewDelegate {
  optional func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
  optional func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
  optional func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
  optional func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
  optional func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
  optional func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
  optional func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
  optional func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
  optional func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String?
  optional func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
  optional func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool
  optional func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath
  optional func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int
  optional func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool
  optional func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool
  optional func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?)
}

// This is a sub-set of UITableViewDataSource.
@objc public protocol TableViewDataSource: NSObjectProtocol {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  optional func numberOfSectionsInTableView(tableView: UITableView) -> Int
  optional func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
  optional func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
  optional func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
  optional func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
  optional func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]?
  optional func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
  optional func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
  optional func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
}

class TableViewCell: UITableViewCell {
  var node: Node? {
    didSet {
      for view in contentView.subviews {
        view.removeFromSuperview()
      }
      if let node = node {
        contentView.addSubview(node.render())
      }
    }
  }
}

public class TableView: UITableView {
  public weak var templateDelegate: TableViewTemplateDelegate?
  public weak var templateDataSource: TableViewTemplateDataSource?

  public weak var tableDelegate: TableViewDelegate? {
    didSet {
      configureTableDelegate()
    }
  }
  public weak var tableDataSource: TableViewDataSource? {
    didSet {
      configureTableDataSource()
    }
  }

  private var delegateInterceptor: Interceptor?
  private var dataSourceInterceptor: Interceptor?

  override weak public var delegate: UITableViewDelegate? {
    set {
      fatalError("TableView requires a tableViewDelegate instead.")
    }
    get {
      return super.delegate
    }
  }

  override weak public var dataSource: UITableViewDataSource? {
    set {
      fatalError("TableView requires a tableViewDataSource instead.")
    }
    get {
      return super.dataSource
    }
  }

  private let cellIdentifier = "TableViewCell"
  private let nodeProvider: NodeProvider
  private var cachedHeaderNode: Node?
  private var cachedFooterNode: Node?
  private lazy var rowNodeCache = [Int: Node]()
  private lazy var rowControllerCache = [Int: TableViewItemController]()
  private lazy var headerNodeCache = [Int: Node]()
  private lazy var headerControllerCache = [Int: TableViewItemController]()
  private lazy var footerNodeCache = [Int: Node]()
  private lazy var footerControllerCache = [Int: TableViewItemController]()

  public init(nodeProvider: NodeProvider, frame: CGRect, style: UITableViewStyle) {
    self.nodeProvider = nodeProvider

    super.init(frame: frame, style: style)

    configureTableDelegate()
    configureTableDataSource()

    registerClass(TableViewCell.self, forCellReuseIdentifier: cellIdentifier)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func reloadData() {
    super.reloadData()

    // TODO(mcudich): Lay out when table bounds actually change.
    let header = headerNode()
    let footer = footerNode()

    header?.measure(CGSize(width: bounds.width, height: CGFloat.max))
    tableHeaderView = header?.render()
    tableFooterView = footer?.render()
  }

  private func headerNode() -> Node? {
    guard let nodeName = templateDelegate?.nodeNameForHeaderInTableView(self) else {
      return nil
    }

    let node = cachedHeaderNode ?? nodeProvider.nodeWithName(nodeName)
    var controller = templateDelegate?.controllerForHeaderInTableView(self)
    controller?.node = node
    node?.model = templateDelegate?.modelForHeaderInTableView(self)
    cachedHeaderNode = node

    return node
  }

  private func footerNode() -> Node? {
    guard let nodeName = templateDelegate?.nodeNameForFooterInTableView(self) else {
      return nil
    }

    let node = cachedFooterNode ?? nodeProvider.nodeWithName(nodeName)
    var controller = templateDelegate?.controllerForFooterInTableView(self)
    controller?.node = node
    node?.model = templateDelegate?.modelForFooterInTableView(self)
    cachedFooterNode = node

    return node
  }

  private func nodeWithIndexPath(indexPath: NSIndexPath) -> Node? {
    guard let templateDataSource = templateDataSource else {
      return nil
    }

    let cacheKey = templateDataSource.tableView(self, cacheKeyForRowAtIndexPath: indexPath)
    if let cacheKey = cacheKey, component = rowNodeCache[cacheKey] {
      return component
    }

    let nodeName = templateDataSource.tableView(self, nodeNameForRowAtIndexPath: indexPath)
    let node = nodeProvider.nodeWithName(nodeName)
    var controller = templateDataSource.tableView(self, controllerForRowAtIndexPath: indexPath)
    controller?.node = node
    node?.model = templateDataSource.tableView(self, modelForRowAtIndexPath: indexPath)
    if let cacheKey = cacheKey {
      rowControllerCache[cacheKey] = controller
      rowNodeCache[cacheKey] = node
    }

    return node
  }

  private func headerNodeWithSection(section: Int) -> Node? {
    guard let templateDelegate = templateDelegate else {
      return nil
    }

    let cacheKey = templateDelegate.tableView(self, cacheKeyForHeaderInSection: section)
    if let cacheKey = cacheKey, node = headerNodeCache[cacheKey] {
      return node
    }

    guard let nodeName = templateDelegate.tableView(self, nodeNameForHeaderInSection: section) else {
      return nil
    }
    let node = nodeProvider.nodeWithName(nodeName)
    var controller = templateDelegate.tableView(self, controllerForHeaderInSection: section)
    controller?.node = node
    node?.model = templateDelegate.tableView(self, modelForHeaderInSection: section)
    if let cacheKey = cacheKey {
      headerControllerCache[cacheKey] = controller
      headerNodeCache[cacheKey] = node
    }

    return node
  }

  private func footerNodeWithSection(section: Int) -> Node? {
    guard let templateDelegate = templateDelegate else {
      return nil
    }

    let cacheKey = templateDelegate.tableView(self, cacheKeyForFooterInSection: section)
    if let cacheKey = cacheKey, node = footerNodeCache[cacheKey] {
      return node
    }

    guard let nodeName = templateDelegate.tableView(self, nodeNameForFooterInSection: section) else {
      return nil
    }
    let node = nodeProvider.nodeWithName(nodeName)
    var controller = templateDelegate.tableView(self, controllerForFooterInSection: section)
    controller?.node = node
    node?.model = templateDelegate.tableView(self, modelForFooterInSection: section)
    if let cacheKey = cacheKey {
      footerControllerCache[cacheKey] = controller
      footerNodeCache[cacheKey] = node
    }

    return node
  }

  private func configureTableDelegate() {
    delegateInterceptor = configureInterceptor(tableDelegate, protocolType: UITableViewDelegate.self)
    super.delegate = delegateInterceptor as! UITableViewDelegate
  }

  private func configureTableDataSource() {
    dataSourceInterceptor = configureInterceptor(tableDataSource, protocolType: UITableViewDataSource.self)
    super.dataSource = dataSourceInterceptor as! UITableViewDataSource
  }

  private func configureInterceptor(target: NSObjectProtocol?, protocolType: Protocol) -> Interceptor {
    let interceptor = Interceptor(target: target, interceptor: self, protocol: protocolType)

    interceptor.registerInterceptableSelector(#selector(UITableViewDelegate.tableView(_:heightForRowAtIndexPath:)))
    interceptor.registerInterceptableSelector(#selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)))
    interceptor.registerInterceptableSelector(#selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)))
    interceptor.registerInterceptableSelector(#selector(UITableViewDelegate.tableView(_:viewForHeaderInSection:)))
    interceptor.registerInterceptableSelector(#selector(UITableViewDelegate.tableView(_:viewForFooterInSection:)))
    interceptor.registerInterceptableSelector(#selector(UITableViewDataSource.tableView(_:cellForRowAtIndexPath:)))

    return interceptor
  }
}

extension TableView {
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return heightForNode(nodeWithIndexPath(indexPath))
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return heightForNode(headerNodeWithSection(section))
  }

  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return heightForNode(footerNodeWithSection(section))
  }

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return headerNodeWithSection(section)?.render()
  }

  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return footerNodeWithSection(section)?.render()
  }

  func heightForNode(node: Node?) -> CGFloat {
    return node?.measure(CGSize(width: bounds.width, height: CGFloat.max)).height ?? 0
  }
}

extension TableView {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell
    if let node = nodeWithIndexPath(indexPath) {
      cell.node = node
    }
    return cell
  }
}
