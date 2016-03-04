import UIKit

public protocol TableViewItemController {
  var node: Node? { set get }
  var model: Model? { set get }
}

public protocol TableViewDelegate: class {
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

  // TODO(mcudich): Add all other UITableViewDelegate methods and proxy them through `self`.
}

public protocol TableViewDataSource: class {
  func tableView(tableView: UITableView, nodeNameForRowAtIndexPath indexPath: NSIndexPath) -> String
  func tableView(tableView: UITableView, modelForRowAtIndexPath indexPath: NSIndexPath) -> Model?
  func tableView(tableView: UITableView, controllerForRowAtIndexPath indexPath: NSIndexPath) -> TableViewItemController?
  // Provide a hash value for the given row to enable component and controller caching.
  func tableView(tableView: UITableView, cacheKeyForRowAtIndexPath indexPath: NSIndexPath) -> Int?

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  func numberOfSectionsInTableView(tableView: UITableView) -> Int

  // TODO(mcudich): Add all other UITableViewDataSource methods and proxy them through `self`.
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
  public weak var templateDelegate: TableViewDelegate?
  public weak var templateDataSource: TableViewDataSource?

  override weak public var delegate: UITableViewDelegate? {
    set {
      if newValue == nil {
        super.delegate = nil
        return
      }
      fatalError("TableView requires a templateDelegate instead.")
    }
    get {
      return super.delegate
    }
  }

  override weak public var dataSource: UITableViewDataSource? {
    set {
      if newValue == nil {
        super.dataSource = nil
        return
      }
      fatalError("TableView requires a templateDataSource instead.")
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

  init(nodeProvider: NodeProvider, frame: CGRect, style: UITableViewStyle) {
    self.nodeProvider = nodeProvider

    super.init(frame: frame, style: style)

    registerClass(TableViewCell.self, forCellReuseIdentifier: cellIdentifier)

    super.delegate = self
    super.dataSource = self
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
}

extension TableView: UITableViewDelegate {
  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return heightForNode(nodeWithIndexPath(indexPath))
  }

  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return heightForNode(headerNodeWithSection(section))
  }

  public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return heightForNode(footerNodeWithSection(section))
  }

  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return headerNodeWithSection(section)?.render()
  }

  public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return footerNodeWithSection(section)?.render()
  }

  private func heightForNode(node: Node?) -> CGFloat {
    return node?.measure(CGSize(width: bounds.width, height: CGFloat.max)).height ?? 0
  }
}

extension TableView: UITableViewDataSource {
  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell
    if let node = nodeWithIndexPath(indexPath) {
      cell.node = node
    }
    return cell
  }

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let templateDataSource = templateDataSource else {
      return 0
    }
    return templateDataSource.tableView(tableView, numberOfRowsInSection: section)
  }

  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    guard let templateDataSource = templateDataSource else {
      return 1
    }
    return templateDataSource.numberOfSectionsInTableView(tableView)
  }
}
