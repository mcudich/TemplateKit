import XCTest
import TemplateKit

class BoxNodeTests: XCTestCase {
  func testSimpleLayout() {
    let parent = BoxNode()
    let child1 = Node()
    let child2 = Node()

    parent.add(child1)
    parent.add(child2)

    parent.width = 100
    parent.height = 20

    child1.width = 25
    child2.height = 20
    child2.flex = 1

    let size = parent.measure(CGSize(width: 100, height: 25))

    XCTAssertEqual(100, size.width)
    XCTAssertEqual(20, size.height)

    XCTAssertEqual(0, child1.frame.minX)
    XCTAssertEqual(0, child1.frame.minY)
    XCTAssertEqual(25, child1.frame.maxX)
    XCTAssertEqual(20, child1.frame.maxY)
    XCTAssertEqual(25, child2.frame.minX)
    XCTAssertEqual(0, child2.frame.minY)
    XCTAssertEqual(100, child2.frame.maxX)
    XCTAssertEqual(20, child2.frame.maxY)
  }

  func testNestedLayout() {
    let parent = BoxNode()
    let child1 = BoxNode()
    let child2 = Node()
    let grandchild1 = Node()
    let grandchild2 = Node()

    parent.add(child1)
    parent.add(child2)
    child1.add(grandchild1)
    child1.add(grandchild2)

    parent.width = 100
    child1.width = 50
    child1.flexDirection = .Column
    child2.flex = 1
    grandchild1.height = 20
    grandchild2.height = 10

    let size = parent.measure(CGSize(width: 100, height: 100))

    XCTAssertEqual(100, size.width)
    XCTAssertEqual(30, size.height)
    XCTAssertEqual(0, child1.frame.minX)
    XCTAssertEqual(0, child1.frame.minY)
    XCTAssertEqual(50, child1.frame.maxX)
    XCTAssertEqual(30, child1.frame.maxY)
    XCTAssertEqual(50, child2.frame.minX)
    XCTAssertEqual(50, child2.frame.minX)
    XCTAssertEqual(100, child2.frame.maxX)
    XCTAssertEqual(0, grandchild1.frame.minX)
    XCTAssertEqual(0, grandchild1.frame.minY)
    XCTAssertEqual(50, grandchild1.frame.maxX)
    XCTAssertEqual(20, grandchild1.frame.maxY)
    XCTAssertEqual(0, grandchild2.frame.minX)
    XCTAssertEqual(20, grandchild2.frame.minY)
    XCTAssertEqual(50, grandchild2.frame.maxX)
    XCTAssertEqual(30, grandchild2.frame.maxY)
  }

  func testLayoutWithText() {
    let parent = BoxNode()
    let child1 = TextNode()
    let child2 = BoxNode()

    parent.add(child1)
    parent.add(child2)

    parent.width = 100
    child1.width = 30
    child2.flex = 1
    child2.height = 10

    child1.text = "This is a long string"

    let size = parent.measure()

    XCTAssertEqual(56, size.height)
    XCTAssertEqual(30, child1.frame.maxX)
    XCTAssertEqual(56, child1.frame.maxY)
  }

  func testPerformTextLayoutOnBackgroundThread() {
    let parent = BoxNode()
    let child1 = TextNode()
    let child2 = BoxNode()

    parent.add(child1)
    parent.add(child2)

    parent.width = 100
    child1.width = 30
    child2.flex = 1
    child2.height = 10

    child1.text = "This is a long string"

    let expectation = expectationWithDescription("text measurement")

    var size = CGSizeZero
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      size = parent.measure()
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(1, handler: nil)

    XCTAssertEqual(56, size.height)
    XCTAssertEqual(30, child1.frame.maxX)
    XCTAssertEqual(56, child1.frame.maxY)
  }
}
