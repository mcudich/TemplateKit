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
  case button
  case text
  case textField
  case image
  case view(UIView)
  case component(AnyClass)

  public func make(_ element: Element, _ owner: Node?) -> Node {
    switch self {
    case .box:
      return NativeNode<Box>(element: element as! ElementData<Box.PropertiesType>, children: element.children?.map { $0.build(with: owner, context: nil) }, owner: owner)
    case .button:
      return Button(element: element, children: nil, owner: owner)
    case .text:
      return NativeNode<Text>(element: element as! ElementData<Text.PropertiesType>, owner: owner)
    case .textField:
      return NativeNode<TextField>(element: element as! ElementData<TextField.PropertiesType>, owner: owner)
    case .image:
      return NativeNode<Image>(element: element as! ElementData<Image.PropertiesType>, owner: owner)
    case .view(let view):
      return ViewNode(view: view, element: element as! ElementData<BaseProperties>, owner: owner)
    case .component(let ComponentType as ComponentCreation.Type):
      return ComponentType.init(element: element, children: nil, owner: owner)
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
}

public func ==(lhs: ElementType, rhs: ElementType) -> Bool {
  switch (lhs, rhs) {
  case (.box, .box), (.button, .button), (.text, .text), (.image, .image), (.textField, .textField):
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
