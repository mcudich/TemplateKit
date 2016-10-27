import Foundation
import CSSParser

public protocol ElementProvider {
  func build(with model: Model) -> Element
  func equals(_ other: ElementProvider?) -> Bool
}

public struct Template: Equatable {
  fileprivate let elementProvider: ElementProvider
  fileprivate let styleSheet: StyleSheet?

  public init(_ elementProvider: ElementProvider, _ styleSheet: StyleSheet? = nil) {
    self.elementProvider = elementProvider
    self.styleSheet = styleSheet
  }

  public func build(with model: Model) -> Element {
    let tree = elementProvider.build(with: model)
    styleSheet?.apply(to: tree)
    return tree
  }
}

public func ==(lhs: Template, rhs: Template) -> Bool {
  return lhs.elementProvider.equals(rhs.elementProvider) && lhs.styleSheet == rhs.styleSheet
}
