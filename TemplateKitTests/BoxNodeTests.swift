import XCTest
@testable import TemplateKit

extension TestView: FlexNodeProvider {}

class BoxNodeTests: XCTestCase {
  func testSimpleLayout() {
    let parent = BoxNode()
    let child1 = ViewNode<TestView>()
    let child2 = ViewNode<TestView>()

    parent.add(child: child1)
    parent.add(child: child2)

    parent.properties = [
      "width": CGFloat(100),
      "height": CGFloat(20)
    ]

    child1.properties = [
      "width": CGFloat(25)
    ]
    child2.properties = [
      "height": CGFloat(20),
      "flex": CGFloat(1)
    ]

    parent.sizeToFit(CGSize(width: 100, height: 25))

    XCTAssertEqual(100, parent.view.calculatedFrame!.width)
    XCTAssertEqual(20, parent.view.calculatedFrame!.height)

    XCTAssertEqual(0, child1.view.calculatedFrame!.minX)
    XCTAssertEqual(0, child1.view.calculatedFrame!.minY)
    XCTAssertEqual(25, child1.view.calculatedFrame!.maxX)
    XCTAssertEqual(20, child1.view.calculatedFrame!.maxY)
    XCTAssertEqual(25, child2.view.calculatedFrame!.minX)
    XCTAssertEqual(0, child2.view.calculatedFrame!.minY)
    XCTAssertEqual(100, child2.view.calculatedFrame!.maxX)
    XCTAssertEqual(20, child2.view.calculatedFrame!.maxY)
  }

  func testNestedLayout() {
    let parent = BoxNode()
    let child1 = BoxNode()
    let child2 = ViewNode<TestView>()
    let grandchild1 = ViewNode<TestView>()
    let grandchild2 = ViewNode<TestView>()

    parent.add(child: child1)
    parent.add(child: child2)
    child1.add(child: grandchild1)
    child1.add(child: grandchild2)

    parent.properties = [
      "width": CGFloat(100)
    ]

    child1.properties = [
      "width": CGFloat(50),
      "flexDirection": FlexDirection.column
    ]
    child2.properties = [
      "flex": CGFloat(1)
    ]
    grandchild1.properties = [
      "height": CGFloat(20)
    ]
    grandchild2.properties = [
      "height": CGFloat(10)
    ]

    parent.sizeToFit(CGSize(width: 100, height: 100))

    XCTAssertEqual(100, parent.view.calculatedFrame!.width)
    XCTAssertEqual(30, parent.view.calculatedFrame!.height)
    XCTAssertEqual(0, child1.view.calculatedFrame!.minX)
    XCTAssertEqual(0, child1.view.calculatedFrame!.minY)
    XCTAssertEqual(50, child1.view.calculatedFrame!.maxX)
    XCTAssertEqual(30, child1.view.calculatedFrame!.maxY)
    XCTAssertEqual(50, child2.view.calculatedFrame!.minX)
    XCTAssertEqual(50, child2.view.calculatedFrame!.minX)
    XCTAssertEqual(100, child2.view.calculatedFrame!.maxX)
    XCTAssertEqual(0, grandchild1.view.calculatedFrame!.minX)
    XCTAssertEqual(0, grandchild1.view.calculatedFrame!.minY)
    XCTAssertEqual(50, grandchild1.view.calculatedFrame!.maxX)
    XCTAssertEqual(20, grandchild1.view.calculatedFrame!.maxY)
    XCTAssertEqual(0, grandchild2.view.calculatedFrame!.minX)
    XCTAssertEqual(20, grandchild2.view.calculatedFrame!.minY)
    XCTAssertEqual(50, grandchild2.view.calculatedFrame!.maxX)
    XCTAssertEqual(30, grandchild2.view.calculatedFrame!.maxY)
  }

  func testLayoutWithText() {
    let parent = BoxNode()
    let child1 = ViewNode<TextView>()
    let child2 = BoxNode()

    parent.add(child: child1)
    parent.add(child: child2)

    parent.properties = [
      "width": CGFloat(100)
    ]
    child1.properties = [
      "width": CGFloat(30),
      "text": "This is a long string"
    ]
    child2.properties = [
      "flex": CGFloat(1),
      "height": CGFloat(10)
    ]

    parent.sizeToFit(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))

    XCTAssertEqual(56, parent.view.calculatedFrame!.height)
    XCTAssertEqual(30, child1.view.calculatedFrame!.maxX)
    XCTAssertEqual(56, child1.view.calculatedFrame!.maxY)
  }

  func testPerformTextLayoutOnBackgroundThread() {
    let parent = BoxNode()
    let child1 = ViewNode<TextView>()
    let child2 = BoxNode()

    parent.add(child: child1)
    parent.add(child: child2)

    parent.properties = [
      "width": CGFloat(100)
    ]
    child1.properties = [
      "width": CGFloat(30),
      "text": "This is a long string"
    ]
    child2.properties = [
      "flex": CGFloat(1),
      "height": CGFloat(10)
    ]

    let expectation = self.expectation(description: "text measurement")

    DispatchQueue.global(qos: .background).async {
      parent.sizeToFit(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)

    XCTAssertEqual(56, parent.view.calculatedFrame!.height)
    XCTAssertEqual(30, child1.view.calculatedFrame!.maxX)
    XCTAssertEqual(56, child1.view.calculatedFrame!.maxY)
  }
}
