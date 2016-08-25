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

protocol Transport {
  static func load(url: URL, completion: @escaping (Result<Data>) -> Void)
}

class NetworkTransport: Transport {
  static func load(url: URL, completion: @escaping (Result<Data>) -> Void) {
    Alamofire.request(url, withMethod: .get).responseData { response in
      switch response.result {
      case .success(let data):
        completion(.success(data))
      case .failure(let error):
        completion(.error(error))
      }
    }
  }
}

class FileTransport: Transport {
  static func load(url: URL, completion: @escaping (Result<Data>) -> Void) {
    do {
      completion(.success(try Data(contentsOf: url)))
    } catch {
      completion(.error(error))
    }
  }
}

class RequestOperation<TransportType: Transport, ParserType: Parser>: Operation {
  typealias OperationCompletionHandler = (URL, ResponseType?) -> Void
  typealias ResponseType = ParserType.ParsedType

  lazy var pendingCallbacks = [CompletionHandler<ResponseType>]()

  private let url: URL
  private let completion: OperationCompletionHandler

  override var isAsynchronous: Bool {
    return false
  }

  override var isExecuting: Bool {
    return _executing
  }

  private var _executing = false {
    willSet {
      willChangeValue(forKey: "isExecuting")
    }
    didSet {
      didChangeValue(forKey: "isExecuting")
    }
  }

  override var isFinished: Bool {
    return _finished
  }

  private var _finished = false {
    willSet {
      willChangeValue(forKey: "isFinished")
    }
    didSet {
      didChangeValue(forKey: "isFinished")
    }
  }

  init(url: URL, completion: OperationCompletionHandler) {
    self.url = url
    self.completion = completion
  }

  override func start() {
    _executing = true

    Alamofire.request(url, withMethod: .get).responseData { [weak self] response in
      switch response.result {
      case .failure(let error):
        self?.fail(withError: error)
      case .success(let value):
        self?.processResponse(with: value)
      }
    }
  }

  private func processResponse(with data: Data) {
    let parser = ParserType()
    do {
      let parsed = try parser.parse(data: data)
      let result = Result.success(parsed)
      for callback in pendingCallbacks {
        callback(result)
      }
      complete(with: result.payload)
    } catch {
      fail(withError: error)
    }
  }

  private func fail(withError error: Error) {
    for callback in pendingCallbacks {
      callback(.error(error))
    }
    complete()
  }

  private func complete(with result: ResponseType? = nil) {
    completion(url, result)

    _executing = false
    _finished = true
  }
}

class ResourceService<TransportType: Transport, ParserType: Parser> {
  typealias ResponseType = ParserType.ParsedType

  private lazy var pendingOperations = [URL: RequestOperation<TransportType, ParserType>]()

  private lazy var operationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 8
    return queue
  }()

  private lazy var cache = [URL: ResponseType]()

  func load(_ url: URL, completion: CompletionHandler<ResponseType>) {
    if let response = cache[url] {
      return completion(.success(response))
    }

    if let pendingOperation = pendingOperations[url] {
      return pendingOperation.pendingCallbacks.append(completion)
    }

    let operation = RequestOperation<TransportType, ParserType>(url: url) { [weak self] url, response in
      let _ = self?.pendingOperations.removeValue(forKey: url)
      self?.cache[url] = response
    }
    operation.pendingCallbacks.append(completion)
    pendingOperations[url] = operation

    operationQueue.addOperation(operation)
  }
}
