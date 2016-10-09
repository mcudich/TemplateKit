import Foundation

public protocol ElementProvider {
  func build(with model: Model) -> Element
  func equals(_ other: ElementProvider?) -> Bool
}

public struct Template: Equatable {
  fileprivate let elementProvider: ElementProvider
  fileprivate let styleSheet: StyleSheet

  public init(elementProvider: ElementProvider, styleSheet: StyleSheet = StyleSheet()) {
    self.elementProvider = elementProvider
    self.styleSheet = styleSheet
  }

  public func build(with model: Model) -> Element {
    var tree = elementProvider.build(with: model)
    tree.applyStyleSheet(styleSheet, parentStyles: DefaultProperties())
    return tree
  }
}

public func ==(lhs: Template, rhs: Template) -> Bool {
  return lhs.elementProvider.equals(rhs.elementProvider) && lhs.styleSheet == rhs.styleSheet
}
