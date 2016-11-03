//
//  Tweet.swift
//  TwitterClientExample
//
//  Created by Matias Cudich on 10/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

import TemplateKit

struct TweetProperties: Properties {
  var core = CoreProperties()
  var tweet: Tweet?

  init() {}

  init(_ properties: [String : Any]) {}

  mutating func merge(_ other: TweetProperties) {
    core.merge(other.core)
    merge(&tweet, other.tweet)
  }
}

func ==(lhs: TweetProperties, rhs: TweetProperties) -> Bool {
  return lhs.tweet == rhs.tweet && lhs.equals(otherProperties: rhs)
}

class TweetItem: Component<EmptyState, TweetProperties, UIView> {
  static let templateURL = Bundle.main.url(forResource: "Tweet", withExtension: "xml")!

  override func render() -> Template {
    return render(TweetItem.templateURL)
  }
}
