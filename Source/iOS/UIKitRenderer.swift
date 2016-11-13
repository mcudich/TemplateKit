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
  case table
  case collection
  case activityIndicator
  case view(UIView)
  case component(ComponentCreation.Type)

  public var tagName: String {
    switch self {
    case .box:
      return "box"
    case .text:
      return "text"
    case .textField:
      return "textfield"
    case .image:
      return "image"
    case .button:
      return "button"
    case .table:
      return "table"
    case .collection:
      return "collection"
    case .activityIndicator:
      return "activityindicator"
    case .component(let ComponentType):
      return "\(ComponentType)"
    default:
      fatalError("Unknown element type")
    }
  }

  public func make(_ element: Element, _ owner: Node?, _ context: Context?) -> Node {
    switch (self, element) {
    case (.box, let element as ElementData<Box.PropertiesType>):
      return NativeNode<Box>(element: element, children: element.children?.map { $0.build(withOwner: owner, context: nil) }, owner: owner, context: context)
    case (.text, let element as ElementData<Text.PropertiesType>):
      return NativeNode<Text>(element: element, owner: owner, context: context)
    case (.textField, let element as ElementData<TextField.PropertiesType>):
      return NativeNode<TextField>(element: element, owner: owner, context: context)
    case (.image, let element as ElementData<Image.PropertiesType>):
      return NativeNode<Image>(element: element, owner: owner, context: context)
    case (.button, _):
      return Button(element: element, children: nil, owner: owner, context: context)
    case (.table, let element as ElementData<TableProperties>):
      return Table(element: element, children: nil, owner: owner, context: context)
    case (.collection, let element as ElementData<CollectionProperties>):
      return Collection(element: element, children: nil, owner: owner, context: context)
    case (.activityIndicator, let element as ElementData<ActivityIndicator.PropertiesType>):
      return NativeNode<ActivityIndicator>(element: element, owner: owner, context: context)
    case (.view(let view), let element as ElementData<DefaultProperties>):
      return ViewNode(view: view, element: element, owner: owner, context: context)
    case (.component(let ComponentType), _):
      return ComponentType.init(element: element, children: nil, owner: owner, context: context)
    default:
      fatalError("Supplied element \(element) does not match type \(self)")
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
  case (.box, .box), (.button, .button), (.text, .text), (.image, .image), (.textField, .textField), (.table, .table), (.activityIndicator, .activityIndicator), (.collection, .collection):
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
