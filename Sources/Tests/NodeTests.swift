import XCTest
import TemplateKit

class NodeTests: XCTestCase {
  func testAddNode() {
    let parent = BoxNode()
    let child = Node()
    parent.add(child)

    XCTAssert(parent.contains(child))
  }

  func testEnumeration() {
    let parent = BoxNode()
    let child1 = Node()
    let child2 = Node()
    let child3 = Node()
    parent.add(child1)
    parent.add(child2)
    parent.add(child3)

    for (index, child) in parent.childNodes.enumerate() {
      switch index {
      case 0:
        XCTAssert(child === child1)
      case 1:
        XCTAssert(child === child2)
      case 2:
        XCTAssert(child === child3)
      default:
        break
      }
    }
  }
}
