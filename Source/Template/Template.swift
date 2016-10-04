import Foundation

public protocol ElementProvider {
  func makeElement(with model: Model) throws -> Element
  func equals(_ other: ElementProvider?) -> Bool
}

public struct Template: Equatable {
  fileprivate let elementProvider: ElementProvider
  fileprivate let styleSheet: StyleSheet?

  init(elementProvider: ElementProvider, styleSheet: StyleSheet?) {
    self.elementProvider = elementProvider
    self.styleSheet = styleSheet
  }

  func makeElement(with model: Model) throws -> Element {
    var tree = try elementProvider.makeElement(with: model)
    if let styleSheet = styleSheet {
      tree.applyStyleSheet(styleSheet, parentStyles: DefaultProperties())
    }
    return tree
  }
}

public func ==(lhs: Template, rhs: Template) -> Bool {
  return lhs.elementProvider.equals(rhs.elementProvider) && lhs.styleSheet == rhs.styleSheet
}
