import Foundation

public protocol ElementProvider {
  func makeElement(with model: Model) throws -> Element
}

public struct Template: Equatable {
  private let elementProvider: ElementProvider
  private let styleSheet: StyleSheet?

  init(elementProvider: ElementProvider, styleSheet: StyleSheet?) {
    self.elementProvider = elementProvider
    self.styleSheet = styleSheet
  }

  func makeElement(with model: Model) throws -> Element {
    var tree = try elementProvider.makeElement(with: model)
    tree.applyStyleSheet(styleSheet)
    return tree
  }
}

public func ==(lhs: Template, rhs: Template) -> Bool {
  return false
}
