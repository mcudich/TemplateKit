import Foundation

class OrderedSet<T: AnyObject> {
  private lazy var storage = NSMutableOrderedSet()

  var array: [T] {
    return storage.array as! [T]
  }

  func add(item: T) {
    storage.addObject(item)
  }

  func remove(item: T) {
    storage.removeObject(item)
  }

  func contains(item: T) -> Bool {
    return storage.containsObject(item)
  }
}