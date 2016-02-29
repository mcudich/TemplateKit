import UIKit

public protocol TableViewDelegate: class {

}

public protocol TableViewDataSource: class {

}


public class TableView: UITableView {
  public weak var templateDelegate: TableViewDelegate?
  public weak var templateDataSource: TableViewDataSource?
}