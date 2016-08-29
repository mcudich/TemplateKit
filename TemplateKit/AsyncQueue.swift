//
//  SerialOperationQueue.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/29/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

typealias Task = (@escaping () -> Void) -> Void

class AsyncOperation: Operation {
  var task: Task?

  override var isAsynchronous: Bool {
    return false
  }

  override var isExecuting: Bool {
    return _executing
  }

  required override init() {}

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

  override func start() {
    _executing = true

    task? {
      self.complete()
    }
  }

  func complete() {
    _executing = false
    _finished = true
  }
}

class AsyncQueue<OperationType: AsyncOperation>: OperationQueue {
  init(maxConcurrentOperationCount: Int) {
    super.init()

    self.maxConcurrentOperationCount = maxConcurrentOperationCount
  }

  func enqueueOperation(withBlock block: Task) {
    let operation = OperationType()
    operation.task = block
    addOperation(operation)
  }
}
