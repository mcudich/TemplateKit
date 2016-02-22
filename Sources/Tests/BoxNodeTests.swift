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
    child2.flex = 1

    let size = parent.measure(CGSize(width: 100, height: 25))

    XCTAssertEqual(100, size.width)
    XCTAssertEqual(20, size.height)

    XCTAssertEqual(0, child1.frame.minX)
    XCTAssertEqual(0, child1.frame.minY)
    XCTAssertEqual(25, child1.frame.maxX)
    XCTAssertEqual(20, child1.frame.maxY)
  }
}
