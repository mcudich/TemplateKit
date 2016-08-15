import XCTest
@testable import TemplateKit

class TestView: UIView, View {
  public static var propertyTypes: [String: ValidationType] {
    return [
      "width": Validation.float
    ]
  }

  public weak var propertyProvider: PropertyProvider?

  public var calculatedFrame: CGRect?

  func render() -> UIView {
    return self
  }
}

class NodeTests: XCTestCase {
  func testAddNode() {
    let parent = BoxNode()
    let child = ViewNode<TestView>()
    parent.add(child: child)

    XCTAssert(parent.contains(child: child))
  }

  func testEnumeration() {
    let parent = BoxNode()
    let child1 = ViewNode<TestView>()
    let child2 = ViewNode<TestView>()
    let child3 = ViewNode<TestView>()
    parent.add(child: child1)
    parent.add(child: child2)
    parent.add(child: child3)

    for (index, child) in parent.children.enumerated() {
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
    let child1 = ViewNode<TextView>()
    let child2 = BoxNode()
    let child3 = ViewNode<TextView>()

    parent.add(child: child1)
    parent.add(child: child2)
    child2.add(child: child3)

    parent.properties = ["width": 100]
    child1.properties = ["width": 50, "text": "This is a test"]
    child2.properties = ["flex": 1, "text": "of rendering"]

    parent.sizeToFit(CGSize.zero)
    let view = parent.render()
    XCTAssertEqual(2, view.subviews.count)
    XCTAssertNotNil(view.subviews.first as? UILabel)
  }


  func testPropertiesWithModel() {
    let node = ViewNode<TestView>()
    node.properties = ["width": "$foo"]
    node.model = FakeModel()
    XCTAssertEqual(CGFloat(50), node.get("width"))
  }
}

struct FakeModel: Model {
  let foo: CGFloat = 50
}
