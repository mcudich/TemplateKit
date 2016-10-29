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
  private lazy var tweetsList: TableView = {
    let tweets = TableView(frame: CGRect.zero, style: .plain, context: self.getContext())
    tweets.tableViewDataSource = self
    tweets.eventTarget = self
    tweets.allowsSelection = false
    return tweets
  }()

  override func didBuild() {
    TwitterClient.shared.fetchSearchResultsWithQuery(query: "donald trump") { tweets in
      self.updateState(stateMutation: { state in
        state.tweets = tweets
      }, completion: {
        DispatchQueue.main.async {
          self.tweetsList.reloadData()
        }
      })
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
    var properties = DefaultProperties()
    properties.core.layout.flex = 1
    return wrappedView(tweetsList, properties)
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
