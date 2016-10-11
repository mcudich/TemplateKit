//
//  NetworkService.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/23/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

typealias CompletionHandler<T> = (Result<T>) -> Void

protocol Parser {
  associatedtype ParsedType

  init()
  func parse(data: Data) throws -> ParsedType
}

public enum CachePolicy {
  case always
  case never
}

class ResourceService<ParserType: Parser> {
  typealias ResponseType = ParserType.ParsedType

  public var cachePolicy: CachePolicy = .always

  private lazy var defaultSession = URLSession(configuration: .default)
  private lazy var requestQueue: DispatchQueue = DispatchQueue(label: "requestQueue")
  private lazy var operationQueue = AsyncQueue<AsyncOperation>(maxConcurrentOperationCount: 8)

  private lazy var pendingOperations = [URL: [CompletionHandler<ResponseType>]]()
  private lazy var cache = [URL: ResponseType]()

  func load(_ url: URL, completion: @escaping CompletionHandler<ResponseType>) {
    requestQueue.async { [weak self] in
      self?.enqueueLoad(url, completion: completion)
    }
  }

  func enqueueLoad(_ url: URL, completion: @escaping CompletionHandler<ResponseType>) {
    if let response = cache[url] {
      return completion(.success(response))
    }

    if pendingOperations[url] != nil {
      pendingOperations[url]?.append(completion)
      return
    }

    pendingOperations[url] = [completion]

    operationQueue.enqueueOperation { [weak self] done in
      self?.defaultSession.dataTask(with: url) { [weak self] data, response, error in
        self?.requestQueue.async {
          if let data = data {
            self?.processResponse(forURL: url, withData: data)
          } else if let error = error {
            self?.fail(forURL: url, withError: error)
          }
          _ = self?.pendingOperations.removeValue(forKey: url)
          done()
        }
      }.resume()
    }
  }

  private func processResponse(forURL url: URL, withData data: Data) {
    let parser = ParserType()
    do {
      let parsed = try parser.parse(data: data)
      if cachePolicy == .always {
        cache[url] = parsed
      }
      processCallbacks(forURL: url, result: .success(parsed))
    } catch {
      fail(forURL: url, withError: error)
    }
  }

  private func fail(forURL url: URL, withError error: Error) {
    processCallbacks(forURL: url, result: .failure(error))
  }

  private func processCallbacks(forURL url: URL, result: Result<ResponseType>) {
    guard let pendingCallbacks = pendingOperations[url] else {
      return
    }
    pendingCallbacks.forEach { $0(result) }
  }
}
