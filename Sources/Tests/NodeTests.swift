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

  func testRendersViewHierarchy() {
    let parent = BoxNode()
    let child1 = TextNode()
    let child2 = BoxNode()
    let child3 = TextNode()

    parent.add(child1)
    parent.add(child2)
    child2.add(child3)

    parent.width = 100
    child1.width = 50
    child1.text = "This is a test"
    child2.flex = 1
    child3.text = "of rendering"

    parent.measure()
    let view = parent.render()
    XCTAssertEqual(2, view.subviews.count)
    XCTAssertNotNil(view.subviews.first as? UILabel)
  }

  func testProperties() {
    let node = Node(properties: ["width": "100", "height": "50"])
    XCTAssertEqual(100, node.width)
    XCTAssertEqual(50, node.height)
  }

  func testPropertiesWithModel() {
    let node = Node(properties: ["width": "$foo"])
    node.model = FakeModel()
    XCTAssertEqual(50, node.width)
  }
}

struct FakeModel: Model {
  let foo: CGFloat = 50
}
