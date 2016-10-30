//
//  TwitterClient.swift
//  TwitterClientExample
//
//  Created by Matias Cudich on 10/27/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import UIKit

import Alamofire
import CryptoSwift
import SwiftyJSON
import SwiftDate
import TemplateKit

struct User: Hashable, Model {
  var id: String?
  var name: String?
  var screenName: String?
  var location: String?
  var url: URL?
  var followers: String?
  var following: String?
  var bannerURL: URL?
  var profileImageURL: URL?
  var description: String?

  var hashValue: Int {
    return id?.hashValue ?? 0
  }
}

func ==(lhs: User, rhs: User) -> Bool {
  return lhs.id == rhs.id
}

struct Tweet: Hashable, Model {
  var id: String?
  var text: String?
  var author: User?
  var createdAt: String?
  var favoriteCount: Int?
  var retweetCount: Int?

  var hashValue: Int {
    return id?.hashValue ?? 0
  }
}

func ==(lhs: Tweet, rhs: Tweet) -> Bool {
  return lhs.id == rhs.id
}

class TwitterClient {
  static let shared = TwitterClient()

  let homeTimelineBaseURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
  let searchBaseURL = "https://api.twitter.com/1.1/search/tweets.json"
  let usersBaseURL = "https://api.twitter.com/1.1/users/show.json"
  let userTimelineBaseURL = "https://api.twitter.com/1.1/statuses/user_timeline.json"
  let favoritesBaseURL = "https://api.twitter.com/1.1/favorites/list.json"

  // TODO(mcudich): Drop all this stuff.
  let consumerKey = "byAYccExen5xosryMVH9X85BK"
  let consumerSecret = "TIHW8Jf9ySDu4pYEP6zUOa1HtCkWRu59YIPyeDn37eDZOrMsAG"
  let token = "2897911-UcFRByCVTMOiNCsfBrg8RPMA2XnIdUxUA7jfrfEv1I"
  let tokenSecret = "cZreTNSuBRAfzFbIr0nKk9PVTMlWa8YWKqCXTcDSpZyB8"

  private lazy var cache = [String: Any]()

  private lazy var utcFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
    return dateFormatter
  }()

  private lazy var friendlyFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.doesRelativeDateFormatting = true
    return dateFormatter
  }()

  let queue = DispatchQueue(label: "TwitterClient")

  func fetchHomeTimeline(callback: @escaping ([Tweet]) -> ()) {
    let cacheKeyValue = cacheKey(homeTimelineBaseURL, params: [:])
    if let cached = cache[cacheKeyValue] {
      return callback(cached as! [Tweet])
    }

    Alamofire.request(homeTimelineBaseURL, headers: constructHeaders(homeTimelineBaseURL))
      .responseData { response in
        switch response.result {
        case .failure(let error):
          print(error)
        case .success(let value):
          self.queue.async {
            let tweets = self.parseTweetsData(value)
            self.cache[cacheKeyValue] = tweets
            callback(tweets)
          }
        }
    }
  }

  func fetchSearchResultsWithQuery(query: String, callback: @escaping ([Tweet]) -> ()) {
    guard !query.isEmpty else {
      callback([])
      return
    }

    let params = ["q": query]

    let cacheKeyValue = cacheKey(searchBaseURL, params: params)
    if let cached = cache[cacheKeyValue] {
      return callback(cached as! [Tweet])
    }

    let headers = constructHeaders(searchBaseURL, parameters: params)
    Alamofire.request(searchBaseURL, parameters: params, headers: headers)
      .responseData { response in
        switch response.result {
        case .failure(let error):
          print(error)
        case .success(let value):
          self.queue.async {
            let tweets = self.parseSearchResultsData(value)
            self.cache[cacheKeyValue] = tweets
            callback(tweets)
          }
        }
    }
  }

  func fetchUserWithScreenName(screenName: String, callback: @escaping (User?) -> ()) {
    guard !screenName.isEmpty else {
      callback(nil)
      return
    }

    let params = ["screen_name": screenName]

    let cacheKeyValue = cacheKey(usersBaseURL, params: params)
    if let cached = cache[cacheKeyValue] {
      return callback(cached as? User)
    }

    let headers = constructHeaders(usersBaseURL, parameters: params)
    Alamofire.request(usersBaseURL, parameters: params, headers: headers)
      .responseData { response in
        switch response.result {
        case .failure(let error):
          print(error)
        case .success(let value):
          self.queue.async {
            let user = self.parseUserData(value)
            self.cache[cacheKeyValue] = user
            callback(user)
          }
        }
    }
  }

  func fetchTimelineWithScreenName(screenName: String, callback: @escaping ([Tweet]) -> ()) {
    guard !screenName.isEmpty else {
      callback([])
      return
    }

    let params = ["screen_name": screenName]

    let cacheKeyValue = cacheKey(userTimelineBaseURL, params: params)
    if let cached = cache[cacheKeyValue] {
      return callback(cached as! [Tweet])
    }

    let headers = constructHeaders(userTimelineBaseURL, parameters: params)
    Alamofire.request(userTimelineBaseURL, parameters: params, headers: headers)
      .responseData { response in
        switch response.result {
        case .failure(let error):
          print(error)
        case .success(let value):
          self.queue.async {
            let tweets = self.parseTweetsData(value)
            self.cache[cacheKeyValue] = tweets
            callback(tweets)
          }
        }
    }
  }

  func fetchFavoritesWithScreenName(screenName: String, callback: @escaping ([Tweet]) -> ()) {
    guard !screenName.isEmpty else {
      callback([])
      return
    }

    let params = ["screen_name": screenName]

    let cacheKeyValue = cacheKey(favoritesBaseURL, params: params)
    if let cached = cache[cacheKeyValue] {
      return callback(cached as! [Tweet])
    }

    let headers = constructHeaders(favoritesBaseURL, parameters: params)
    Alamofire.request(favoritesBaseURL, parameters: params, headers: headers)
      .responseData { response in
        switch response.result {
        case .failure(let error):
          print(error)
        case .success(let value):
          self.queue.async {
            let tweets = self.parseTweetsData(value)
            self.cache[cacheKeyValue] = tweets
            callback(tweets)
          }
        }
    }
  }

  private func constructHeaders(_ baseURL: String, parameters: [String: String]? = nil) -> [String: String] {
    var oauthMap = [String: String]()
    oauthMap["oauth_consumer_key"] = consumerKey
    oauthMap["oauth_nonce"] = NSUUID().uuidString
    oauthMap["oauth_signature_method"] = "HMAC-SHA1"
    oauthMap["oauth_timestamp"] = String(Int(NSDate().timeIntervalSince1970))
    oauthMap["oauth_token"] = token
    oauthMap["oauth_version"] = "1.0"

    var signatureMap = oauthMap
    if let parameters = parameters {
      for (key, value) in parameters {
        signatureMap[key] = value
      }
    }

    let keys = signatureMap.keys.sorted()
    var sortedSignatureMap = OrderedDictionary<String, String>()
    for key in keys {
      sortedSignatureMap[key] = signatureMap[key]
    }

    var validChars = CharacterSet.urlHostAllowed
    validChars.remove(charactersIn: ":&=?+")

    var queryString = ""
    var count = sortedSignatureMap.count
    for (index, (key, value)) in sortedSignatureMap.enumerated() {
      queryString += escapeHeaderValue(key, validChars)
      queryString += "="
      queryString += escapeHeaderValue(value, validChars)
      if index < count - 1 {
        queryString += "&"
      }
    }

    var signatureInput = "GET&"
    signatureInput += escapeHeaderValue(baseURL, validChars)
    signatureInput += "&"
    signatureInput += escapeHeaderValue(queryString, validChars)

    var signingKey = ""
    signingKey += escapeHeaderValue(consumerSecret, validChars)
    signingKey += "&"
    signingKey += escapeHeaderValue(tokenSecret, validChars)

    let data = signatureInput.data(using: .utf8)!
    let key = signingKey.data(using: .utf8)!.bytes
    let signature = try! data.authenticate(with: HMAC(key: key, variant: HMAC.Variant.sha1))

    oauthMap["oauth_signature"] = signature.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

    var oauthString = "OAuth "
    count = oauthMap.count
    for (index, entry) in oauthMap.enumerated() {
      oauthString += escapeHeaderValue(entry.key, validChars)
      oauthString += "=\""
      oauthString += escapeHeaderValue(entry.value, validChars)
      oauthString += "\""
      if index < count - 1 {
        oauthString += ", "
      }
    }

    return ["Authorization": oauthString]
  }

  private func parseSearchResultsData(_ data: Data) -> [Tweet] {
    let response = JSON(data: data)
    return parseTweets(response["statuses"].arrayValue)
  }

  private func parseTweetsData(_ data: Data) -> [Tweet] {
    let tweets = JSON(data: data)
    return parseTweets(tweets.arrayValue)
  }

  private func parseTweets(_ tweets: [JSON]) -> [Tweet] {
    return tweets.map { tweetData in
      var tweet = Tweet()
      tweet.id = tweetData["id_str"].string
      tweet.text = decodeHTML(tweetData["text"].string)
      let date = utcFormatter.date(from: tweetData["created_at"].stringValue)!
      tweet.createdAt = try! date.colloquialSinceNow().colloquial
      tweet.favoriteCount = tweetData["favorite_count"].int
      tweet.retweetCount = tweetData["retweet_data"].int
      tweet.author = parseUser(tweetData["user"])

      return tweet
    }
  }

  private func parseUserData(_ data: Data) -> User {
    let response = JSON(data: data)
    return parseUser(response)
  }

  private func parseUser(_ user: JSON) -> User {
    let response = user.dictionaryValue

    var user = User()
    user.id = response["id_str"]?.string
    user.name = response["name"]?.string
    user.screenName = "@" + response["screen_name"]!.stringValue
    user.location = response["location"]?.string
    if let url = response["entities"]?["url"]["urls"].array?.first?.dictionary {
      user.url = url["display_url"]?.URL
    }
    user.followers = String(response["followers_count"]!.intValue)
    user.following = String(response["friends_count"]!.intValue)
    user.profileImageURL = response["profile_image_url_https"]?.URL
    user.description = decodeHTML(response["description"]?.string)
    if let bannerURL = response["profile_banner_url"]?.string {
      user.bannerURL = URL(string: bannerURL + "/600x200")
    }
    return user
  }

  private func decodeHTML(_ html: String?) -> String {
    guard let html = html else {
      return ""
    }
    let encodedData = html.data(using: .utf8)!
    let attributedOptions: [String: Any] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue)
    ]
    let attributedString = try? NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
    return attributedString?.string ?? ""
  }

  private func escapeHeaderValue(_ value: String, _ allowedChars: CharacterSet) -> String {
    return value.addingPercentEncoding(withAllowedCharacters: allowedChars)!
  }

  private func cacheKey(_ baseURL: String, params: [String: String]) -> String {
    var cacheKeyValue = baseURL + "?"
    for (key, value) in params {
      cacheKeyValue += key
      cacheKeyValue += "="
      cacheKeyValue += value
      cacheKeyValue += "&"
    }
    return cacheKeyValue
  }
}
