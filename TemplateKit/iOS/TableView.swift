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
public protocol TableViewDataSource: NSObjectProtocol {
  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element
  func tableView(_ tableView: TableView, cacheKeyForRowAtIndexPath indexPath: IndexPath) -> Int

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
  func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool
  func tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool
  func sectionIndexTitlesForTableView(_ tableView: UITableView) -> [String]?
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
  func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath)
  func tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath)
}

public extension TableViewDataSource {
  func tableView(_ tableView: TableView, cacheKeyForRowAtIndexPath indexPath: IndexPath) -> Int {
    return IndexPath(row: indexPath.row, section: indexPath.section).hashValue
  }
  func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return nil
  }
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return nil
  }
  func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
    return false
  }
  func tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
    return false
  }
  func sectionIndexTitlesForTableView(_ tableView: UITableView) -> [String]? {
    return nil
  }
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
    return 0
  }
  func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
  }
  func tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
  }
}

class TableViewCell: UITableViewCell {
  var component: Component? {
    didSet {
      for view in contentView.subviews {
        view.removeFromSuperview()
      }
      if let component = component {
        contentView.addSubview(component.builtView as! UIView)
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
  fileprivate lazy var rowComponentCache = [Int: Component]()

  private let context: Context
  private lazy var operationQueue = AsyncQueue<AsyncOperation>(maxConcurrentOperationCount: 1)
  private var delegateProxy: (DelegateProxyProtocol & UITableViewDelegate)?
  private var dataSourceProxy: (DelegateProxyProtocol & UITableViewDataSource)?

  public init(frame: CGRect, style: UITableViewStyle, context: Context) {
    self.context = context

    super.init(frame: frame, style: style)

    configureTableDelegate()
    configureTableDataSource()

    register(TableViewCell.self, forCellReuseIdentifier: cellIdentifier)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate func component(withIndexPath indexPath: IndexPath) -> Component? {
    guard let tableViewDataSource = tableViewDataSource else {
      return nil
    }

    let cacheKey = tableViewDataSource.tableView(self, cacheKeyForRowAtIndexPath: indexPath)
    if let cachedComponent = rowComponentCache[cacheKey] {
      return cachedComponent
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
    precacheComponents(at: indexPaths)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.insertRows(at: indexPaths, with: animation)
        done()
      }
    }
  }

  public override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
    purgeComponents(at: indexPaths)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.deleteRows(at: indexPaths, with: animation)
        done()
      }
    }
  }

  public override func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
    precacheComponents(in: sections)
    operationQueue.enqueueOperation { done in
      super.insertSections(sections, with: animation)
      done()
    }
  }

  public override func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
    purgeComponents(in: sections)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.deleteSections(sections, with: animation)
        done()
      }
    }
  }

  public override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.moveRow(at: indexPath, to: newIndexPath)
        done()
      }
    }
  }

  public override func moveSection(_ section: Int, toSection newSection: Int) {
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.moveSection(section, toSection: newSection)
        done()
      }
    }
  }

  public override func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
    precacheComponents(at: indexPaths)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.reloadRows(at: indexPaths, with: animation)
        done()
      }
    }
  }

  public override func reloadSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
    precacheComponents(in: sections)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.reloadSections(sections, with: animation)
        done()
      }
    }
  }

  public override func reloadData() {
    guard let tableViewDataSource = tableViewDataSource else {
      return
    }

    let sectionCount = tableViewDataSource.numberOfSectionsInTableView(self)
    let indexPaths: [IndexPath] = (0..<sectionCount).reduce([]) { previous, section in
      return previous + self.indexPaths(forSection: section)
    }

    precacheComponents(at: indexPaths)
    operationQueue.enqueueOperation { done in
      DispatchQueue.main.async {
        super.reloadData()
        done()
      }
    }
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

  func precacheComponents(at indexPaths: [IndexPath]) {
    operationQueue.enqueueOperation { done in
      self.performPrecache(for: indexPaths, done: done)
    }
  }

  func precacheComponents(in sections: IndexSet) {
    operationQueue.enqueueOperation { done in
      let indexPaths: [IndexPath] = sections.reduce([]) { previous, section in
        return previous + self.indexPaths(forSection: section)
      }
      self.performPrecache(for: indexPaths, done: done)
    }
  }

  func performPrecache(for indexPaths: [IndexPath], done: @escaping () -> Void) {
    guard let tableViewDataSource = tableViewDataSource, indexPaths.count > 0 else {
      return done()
    }

    var pending = indexPaths.count
    for indexPath in indexPaths {
      let cacheKey = tableViewDataSource.tableView(self, cacheKeyForRowAtIndexPath: indexPath)
      let element = tableViewDataSource.tableView(self, elementAtIndexPath: indexPath)
      UIKitRenderer.render(element, context: context) { [weak self] component, view in
        self?.rowComponentCache[cacheKey] = component
        pending -= 1
        if pending == 0 {
          done()
        }
      }
    }
  }

  func purgeComponents(at indexPaths: [IndexPath]) {
    operationQueue.enqueueOperation { done in
      self.performPurge(for: indexPaths, done: done)
    }
  }

  func purgeComponents(in sections: IndexSet) {
    operationQueue.enqueueOperation { done in
      let indexPaths: [IndexPath] = sections.reduce([]) { previous, section in
        return previous + self.indexPaths(forSection: section)
      }
      self.performPurge(for: indexPaths, done: done)
    }
  }

  func performPurge(for indexPaths: [IndexPath], done: @escaping () -> Void) {
    guard let tableViewDataSource = tableViewDataSource, indexPaths.count > 0 else {
      return done()
    }

    for indexPath in indexPaths {
      let cacheKey = tableViewDataSource.tableView(self, cacheKeyForRowAtIndexPath: indexPath)
      self.rowComponentCache.removeValue(forKey: cacheKey)
    }
    done()
  }
}

extension TableView {
  func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
    return heightForComponent(component(withIndexPath: indexPath))
  }

  func heightForComponent(_ component: Component?) -> CGFloat {
    return component?.builtView?.frame.height ?? 0
  }
}

extension TableView {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rowComponentCache.count
  }

  func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
    let cell = dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
    if let component = component(withIndexPath: indexPath) {
      cell.component = component
    }
    return cell
  }
}
