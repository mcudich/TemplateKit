//
//  ImageService.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

import Alamofire
typealias ImageHandler = UIImage -> ()

final class ImageRequestOperation: NSOperation {
  private let url: NSURL
  private lazy var pendingCallbacks = [ImageHandler]()
  private var imageCompletionBlock: ((NSURL, UIImage) -> ())?

  override var asynchronous: Bool {
    return false
  }

  override var executing: Bool {
    return _executing
  }

  private var _executing = false {
    willSet {
      willChangeValueForKey("isExecuting")
    }
    didSet {
      didChangeValueForKey("isExecuting")
    }
  }

  override var finished: Bool {
    return _finished
  }

  private var _finished = false {
    willSet {
      willChangeValueForKey("isFinished")
    }
    didSet {
      didChangeValueForKey("isFinished")
    }
  }

  init(url: NSURL) {
    self.url = url
  }

  override func start() {
    _executing = true

    Alamofire.request(.GET, url).responseData { [weak self] response in
      switch response.result {
      case .Failure(let error):
        print(error)
      case .Success(let value):
        self?.processResponse(value)
      }
    }
  }

  private func processResponse(data: NSData) {
    // TODO(mcudich): Handle errors.
    guard let image = UIImage(data: data) else {
      return
    }

    dispatch_async(dispatch_get_main_queue()) {
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

  private lazy var pendingOperations = [NSURL: ImageRequestOperation]()
  // TODO(mcudich): Use a capacity-limited LRU cache.
  private lazy var imageCache = [NSURL: UIImage]()

  private lazy var imageOperationQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 8
    return queue
  }()

  func loadImageWithURL(url: NSURL, completion: ImageHandler) {
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

  private func fillCache(url: NSURL, image: UIImage) {
    pendingOperations.removeValueForKey(url)
    imageCache[url] = image
  }
}
