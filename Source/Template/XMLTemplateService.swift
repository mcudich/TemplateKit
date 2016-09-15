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
  let resourceService = ResourceService<XMLTemplateParser>()

  private lazy var cache = [URL: Template]()

  public init() {
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
          }
        case .failure(_):
          completion(.failure(TemplateKitError.missingTemplate("Template not found at \(url)")))
        }
      }
    }
  }

  public func watchTemplates(withURLs urls: [URL], completion: @escaping (Result<Void>) -> Void) {
    let time = DispatchTime.now() + DispatchTimeInterval.seconds(5)
    DispatchQueue.main.asyncAfter(deadline: time) {
      self.fetchTemplates(withURLs: urls) { result in
        completion(result)
        self.watchTemplates(withURLs: urls, completion: completion)
      }
    }
  }
}
