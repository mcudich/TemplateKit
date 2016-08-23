//
//  ViewController.swift
//  Example
//
//  Created by Matias Cudich on 8/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import UIKit
import TemplateKit

struct TestModel: Model {
  let title: String
  let description: String
}

class ContainerView: UIView {
  private lazy var spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.startAnimating()
    return spinner
  }()

  fileprivate var tableView: TableView? {
    didSet {
      guard let tableView = tableView else { return }
      spinner.removeFromSuperview()
      addSubview(tableView)
      setNeedsLayout()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(spinner)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    spinner.sizeToFit()
    spinner.frame = CGRect(x: (bounds.width - spinner.bounds.width) / 2, y: (bounds.height - spinner.bounds.height) / 2, width: spinner.bounds.width, height: spinner.bounds.height)
    tableView?.frame = bounds
  }
}

class ViewController: UIViewController {
  fileprivate lazy var client: TemplateClient = {
    let client = TemplateClient(fetchStrategy: .local(Bundle.main, nil))
    client.delegate = self
    return client
  }()

  fileprivate lazy var containerView: ContainerView = ContainerView()

  fileprivate lazy var tableView: TableView = {
    let tableView = TableView(nodeProvider: self, frame: CGRect.zero, style: .plain)

    tableView.tableViewDataSource = self

    return tableView
  }()

  override func loadView() {
    view = containerView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    client.fetchTemplates()
  }
}

extension ViewController: TemplateClientDelegate {
  func templatesDidLoad() {
    containerView.tableView = tableView
  }

  func templatesDidFailToLoad(withError error: Error) {
    // TODO(mcudich): Show error.
  }
}

extension ViewController: NodeProvider {
  func node(withName name: String, properties: [String: Any]?) -> Node? {
    return client.node(withName: name, properties: properties)
  }
}

extension ViewController: TableViewDataSource {
  func tableView(_ tableView: TableView, nodeNameForRowAtIndexPath indexPath: IndexPath) -> String {
    return "Test"
  }

  func tableView(_ tableView: TableView, propertiesForRowAtIndexPath indexPath: IndexPath) -> [String: Any]? {
    return ["model": TestModel(title: "my title", description: "something")]
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
}
