//
//  App.swift
//  TwitterClientExample
//
//  Created by Matias Cudich on 10/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

import TemplateKit

struct AppState: State {
  var tweets = [Tweet]()
}

func ==(lhs: AppState, rhs: AppState) -> Bool {
  return lhs.tweets == rhs.tweets
}

class App: Component<AppState, DefaultProperties, UIView> {
  override func didBuild() {
    TwitterClient.shared.fetchSearchResultsWithQuery(query: "donald trump") { tweets in
      self.updateState { state in
        state.tweets = tweets
      }
    }
  }

  override func render() -> Template {
    var properties = DefaultProperties()
    properties.core.layout = self.properties.core.layout
    let tree = box(properties, [
      renderTweets()
    ])

    return Template(tree)
  }

  private func renderTweets() -> Element {
    var properties = TableProperties()
    properties.core.layout.flex = 1
    properties.tableViewDataSource = self
    properties.itemKeys = state.tweets.map { $0 }

    return table(properties)
  }
}

extension App: TableViewDataSource {
  func tableView(_ tableView: TableView, elementAtIndexPath indexPath: IndexPath) -> Element {
    var properties = TweetProperties()
    properties.tweet = state.tweets[indexPath.row]
    properties.core.layout.width = self.properties.core.layout.width
    return component(TweetItem.self, properties)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return state.tweets.count
  }
}
