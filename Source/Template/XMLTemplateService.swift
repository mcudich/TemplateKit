//
//  XMLTemplateService.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSParser

class XMLTemplateParser: Parser {
  typealias ParsedType = XMLDocument

  required init() {}

  func parse(data: Data) throws -> XMLDocument {
    return try XMLDocument(data: data)
  }
}

class StyleSheetParser: Parser {
  typealias ParsedType = String

  required init() {}

  func parse(data: Data) -> String {
    return String(data: data, encoding: .utf8) ?? ""
  }
}

public class XMLTemplateService: TemplateService {
  public var cachePolicy: CachePolicy {
    set {
      templateResourceService.cachePolicy = newValue
    }
    get {
      return templateResourceService.cachePolicy
    }
  }

  public var liveReloadInterval = DispatchTimeInterval.seconds(5)

  let templateResourceService = ResourceService<XMLTemplateParser>()
  let styleSheetResourceService = ResourceService<StyleSheetParser>()

  private let liveReload: Bool
  public lazy var templates = [URL: Template]()
  private lazy var observers = [URL: NSHashTable<AnyObject>]()

  public init(liveReload: Bool = false) {
    self.liveReload = liveReload
  }

  public func fetchTemplates(withURLs urls: [URL], completion: @escaping (Result<Void>) -> Void) {
    if cachePolicy == .never {
      URLCache.shared.removeAllCachedResponses()
    }
    var pendingURLs = Set(urls)
    for url in urls {
      templateResourceService.load(url) { [weak self] result in
        switch result {
        case .success(let templateXML):
          guard let componentElement = templateXML.componentElement else {
            completion(.failure(TemplateKitError.parserError("No component element found in template at \(url)")))
            return
          }

          self?.resolveStyles(for: templateXML, at: url) { styleSheet in
            self?.templates[url] = Template(componentElement, styleSheet ?? StyleSheet())
            pendingURLs.remove(url)
            if pendingURLs.isEmpty {
              completion(.success())
              if self?.liveReload ?? false {
                self?.watchTemplates(withURLs: urls)
              }
            }
          }
        case .failure(_):
          pendingURLs.remove(url)
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

  private func resolveStyles(for template: XMLDocument, at relativeURL: URL, completion: @escaping (StyleSheet?) -> Void) {
    var urls = [URL]()
    var sheets = [String](repeating: "", count: template.styleElements.count)
    for (index, styleElement) in template.styleElements.enumerated() {
      if let urlString = styleElement.attributes["url"], let url = URL(string: urlString, relativeTo: relativeURL) {
        urls.append(url)
      } else {
        sheets[index] = styleElement.value ?? ""
      }
    }

    let done = { (fetchedSheets: [String]) in
      completion(StyleSheet(string: fetchedSheets.joined()))
    }

    var pendingURLs = Set(urls)
    if pendingURLs.isEmpty {
      return done(sheets)
    }

    for (index, url) in urls.enumerated() {
      styleSheetResourceService.load(url) { result in
        pendingURLs.remove(url)
        switch result {
        case .success(let sheetString):
          sheets[index] = sheetString
          if pendingURLs.isEmpty {
            done(sheets)
          }
        case .failure(_):
          done(sheets)
        }
      }
    }
  }

  private func watchTemplates(withURLs urls: [URL]) {
    let time = DispatchTime.now() + liveReloadInterval
    DispatchQueue.main.asyncAfter(deadline: time) {
      let cachedCopies = self.templates
      self.fetchTemplates(withURLs: urls) { [weak self] result in
        for url in urls {
          if self?.templates[url] != cachedCopies[url], let observers = self?.observers[url] {
            for observer in observers.allObjects {
              (observer as! Node).forceUpdate()
            }
          }
        }
      }
    }
  }
}

extension XMLDocument {
  var hasRemoteStyles: Bool {
    return styleElements.contains { element in
      return element.attributes["url"] != nil
    }
  }

  var styleElements: [XMLElement] {
    return root?.children.filter { candidate in
      return candidate.name == "style"
    } ?? []
  }

  var componentElement: XMLElement? {
    return root?.children.first { candidate in
      return candidate.name != "style"
    }
  }
}

extension XMLElement: ElementProvider {
  func build(with model: Model) -> Element {
    let resolvedProperties = model.resolve(properties: attributes)
    return NodeRegistry.shared.buildElement(with: name, properties: resolvedProperties, children: children.map { $0.build(with: model) })
  }

  func equals(_ other: ElementProvider?) -> Bool {
    guard let other = other as? XMLElement else {
      return false
    }
    return self == other
  }
}
