//
//  ImageService.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

import Alamofire
typealias ImageHandler = (UIImage) -> ()

final class ImageRequestOperation: Operation {
  private let url: URL
  private lazy var pendingCallbacks = [ImageHandler]()
  private var imageCompletionBlock: ((URL, UIImage) -> ())?

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

  init(url: URL) {
    self.url = url
  }

  override func start() {
    _executing = true

    Alamofire.request(url, withMethod: .get).responseData { [weak self] response in
      switch response.result {
      case .failure(let error):
        print(error)
      case .success(let value):
        self?.processResponse(with: value)
      }
    }
  }

  private func processResponse(with data: Data) {
    // TODO(mcudich): Handle errors.
    guard let image = UIImage(data: data) else {
      return
    }

    DispatchQueue.main.async {
      for callback in self.pendingCallbacks {
        callback(image)
      }
    }
    imageCompletionBlock?(url, image)
    _executing = false
    _finished = true
  }
}

final class ImageService {
  static let shared = ImageService()

  private lazy var pendingOperations = [URL: ImageRequestOperation]()
  // TODO(mcudich): Use a capacity-limited LRU cache.
  private lazy var imageCache = [URL: UIImage]()

  private lazy var imageOperationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 8
    return queue
  }()

  func loadImage(withURL url: URL, completion: ImageHandler) {
    if let image = imageCache[url] {
      return completion(image)
    }

    if let pendingOperation = pendingOperations[url] {
      pendingOperation.pendingCallbacks.append(completion)
      return
    }

    let operation = ImageRequestOperation(url: url)
    operation.pendingCallbacks.append(completion)
    operation.imageCompletionBlock = fillCache
    pendingOperations[url] = operation

    imageOperationQueue.addOperation(operation)
  }

  private func fillCache(url: URL, image: UIImage) {
    pendingOperations.removeValue(forKey: url)
    imageCache[url] = image
  }
}
