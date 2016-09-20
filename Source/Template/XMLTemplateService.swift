//
//  XMLTemplateService.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class XMLTemplateParser: Parser {
  typealias ParsedType = Template

  required init() {}

  func parse(data: Data) throws -> Template {
    return try Template(xml: data)
  }
}

public class XMLTemplateService: TemplateService {
  public var cachePolicy: CachePolicy {
    set {
      resourceService.cachePolicy = newValue
    }
    get {
      return resourceService.cachePolicy
    }
  }

  public var liveReloadInterval = DispatchTimeInterval.seconds(5)

  let resourceService = ResourceService<XMLTemplateParser>()

  private let liveReload: Bool
  private lazy var cache = [URL: Template]()
  private lazy var observers = [URL: NSHashTable<AnyObject>]()

  public init(liveReload: Bool = false) {
    self.liveReload = liveReload
  }

  public func element(withLocation location: URL, properties: [String: Any] = [:]) throws -> Element {
    guard let element = try cache[location]?.makeElement(with: properties) else {
      throw TemplateKitError.missingTemplate("Template not found for \(location)")
    }
    return element
  }

  public func fetchTemplates(withURLs urls: [URL], completion: @escaping (Result<Void>) -> Void) {
    var expectedCount = urls.count
    if cachePolicy == .never {
      URLCache.shared.removeAllCachedResponses()
    }
    for url in urls {
      resourceService.load(url) { [weak self] result in
        expectedCount -= 1
        switch result {
        case .success(let template):
          self?.cache[url] = template
          if expectedCount == 0 {
            completion(.success())
            if self?.liveReload ?? false {
              self?.watchTemplates(withURLs: urls)
            }
          }
        case .failure(_):
          completion(.failure(TemplateKitError.missingTemplate("Template not found at \(url)")))
        }
      }
    }
  }

  public func addObserver(observer: Node, forLocation location: URL) {
    if !liveReload {
      return
    }
    let observers = self.observers[location] ?? NSHashTable.weakObjects()

    observers.add(observer as AnyObject)
    self.observers[location] = observers
  }

  public func removeObserver(observer: Node, forLocation location: URL) {
    observers[location]?.remove(observer as AnyObject)
  }

  private func watchTemplates(withURLs urls: [URL]) {
    let time = DispatchTime.now() + liveReloadInterval
    DispatchQueue.main.asyncAfter(deadline: time) {
      let cachedCopies = self.cache
      self.fetchTemplates(withURLs: urls) { [weak self] result in
        for url in urls {
          if self?.cache[url] != cachedCopies[url], let observers = self?.observers[url] {
            for observer in observers.allObjects {
              (observer as! Node).forceUpdate()
            }
          }
        }
      }
    }
  }
}
