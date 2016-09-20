//
//  UIKitRenderer.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public enum ElementType: ElementRepresentable {
  case box
  case text
  case textField
  case image
  case view(UIView)
  case component(AnyClass)

  public func make(_ properties: [String: Any], _ children: [Element]?, _ owner: Node?) -> Node {
    switch self {
    case .box:
      return NativeNode<Box>(properties: BaseProperties(properties), children: children?.map { $0.build(with: owner) }, owner: owner)
    case .text:
      return NativeNode<Text>(properties: TextProperties(properties), owner: owner)
    case .textField:
      return NativeNode<TextField>(properties: TextFieldProperties(properties), owner: owner)
    case .image:
      return NativeNode<Image>(properties: ImageProperties(properties), owner: owner)
    case .view(let view):
      return ViewNode(view: view, properties: BaseProperties([:]), owner: owner)
    case .component(let ComponentType as Node.Type):
      return ComponentType.init(properties: properties, children: nil, owner: owner)
    default:
      fatalError("Unknown element type")
    }
  }

  public func equals(_ other: ElementRepresentable) -> Bool {
    guard let otherType = other as? ElementType else {
      return false
    }
    return self == otherType
  }

  static func fromRaw(_ rawValue: String) throws -> ElementType {
    switch rawValue {
    case "box":
      return .box
    case "text":
      return .text
    case "textfield":
      return .textField
    case "image":
      return .image
    default:
      return try .component(NodeRegistry.shared.componentType(for: rawValue))
    }
  }
}

public func ==(lhs: ElementType, rhs: ElementType) -> Bool {
  switch (lhs, rhs) {
  case (.box, .box), (.text, .text), (.image, .image), (.textField, .textField):
    return true
  case (.view(let lhsView), .view(let rhsView)):
    return lhsView === rhsView
  case (.component(let lhsClass), .component(let rhsClass)):
    return lhsClass == rhsClass
  default:
    return false
  }
}

class DefaultContext: Context {
  var templateService: TemplateService = XMLTemplateService()
  var updateQueue: DispatchQueue = DispatchQueue(label: "UIKitRenderer")
}

public class UIKitRenderer: Renderer {
  public typealias ViewType = UIView

  public static var defaultContext: Context = DefaultContext()
}
