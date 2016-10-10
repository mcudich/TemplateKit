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
  case textfield
  case image
  case view(UIView)
  case component(ComponentCreation.Type)

  public var tagName: String {
    switch self {
    case .box:
      return "box"
    case .text:
      return "text"
    case .textfield:
      return "textfield"
    case .image:
      return "image"
    case .button:
      return "button"
    case .component(let ComponentType):
      return "\(ComponentType)"
    default:
      fatalError("Unknown element type")
    }
  }

  public func make(_ element: Element, _ owner: Node?, _ context: Context?) -> Node {
    switch self {
    case .box:
      return NativeNode<Box>(element: element as! ElementData<Box.PropertiesType>, children: element.children?.map { $0.build(with: owner, context: nil) }, owner: owner, context: context)
    case .text:
      return NativeNode<Text>(element: element as! ElementData<Text.PropertiesType>, owner: owner, context: context)
    case .textfield:
      return NativeNode<TextField>(element: element as! ElementData<TextField.PropertiesType>, owner: owner, context: context)
    case .image:
      return NativeNode<Image>(element: element as! ElementData<Image.PropertiesType>, owner: owner, context: context)
    case .button:
      return Button(element: element, children: nil, owner: owner, context: context)
    case .view(let view):
      return ViewNode(view: view, element: element as! ElementData<DefaultProperties>, owner: owner, context: context)
    case .component(let ComponentType):
      return ComponentType.init(element: element, children: nil, owner: owner, context: context)
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
  case (.box, .box), (.button, .button), (.text, .text), (.image, .image), (.textfield, .textfield):
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
  let templateService: TemplateService = XMLTemplateService()
  let updateQueue: DispatchQueue = DispatchQueue(label: "UIKitRenderer")
}

public class UIKitRenderer: Renderer {
  public typealias ViewType = UIView

  public static let defaultContext: Context = DefaultContext()
}
