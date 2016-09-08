//
//  NetworkService.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/23/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import Alamofire

typealias CompletionHandler<T> = (Result<T>) -> Void

protocol Parser {
  associatedtype ParsedType

  init()
  func parse(data: Data) throws -> ParsedType
}

class ResourceService<ParserType: Parser> {
  typealias ResponseType = ParserType.ParsedType

  private lazy var requestQueue: DispatchQueue = DispatchQueue(label: "requestQueue")
  private lazy var operationQueue = AsyncQueue<AsyncOperation>(maxConcurrentOperationCount: 8)

  private lazy var pendingOperations = [URL: [CompletionHandler<ResponseType>]]()
  private lazy var cache = [URL: ResponseType]()

  func load(_ url: URL, completion: @escaping CompletionHandler<ResponseType>) {
    requestQueue.async {
      self.enqueueLoad(url, completion: completion)
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

    operationQueue.enqueueOperation { done in
      Alamofire.request(url, method: .get).responseData(queue: self.requestQueue) { [weak self] response in
        switch response.result {
        case .failure(let error):
          self?.fail(forURL: url, withError: error)
        case .success(let value):
          self?.processResponse(forURL: url, withData: value)
        }
        let _ = self?.pendingOperations.removeValue(forKey: url)
        done()
      }
    }
  }

  private func processResponse(forURL url: URL, withData data: Data) {
    let parser = ParserType()
    do {
      let parsed = try parser.parse(data: data)
      cache[url] = parsed
      processCallbacks(forURL: url, result: .success(parsed))
    } catch {
      fail(forURL: url, withError: error)
    }
  }

  private func fail(forURL url: URL, withError error: Error) {
    processCallbacks(forURL: url, result: .error(error))
  }

  private func processCallbacks(forURL url: URL, result: Result<ResponseType>) {
    guard let pendingCallbacks = pendingOperations[url] else {
      return
    }
    pendingCallbacks.forEach { $0(result) }
  }
}
