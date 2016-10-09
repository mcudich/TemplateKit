//
//  Rendering.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public extension CompositeComponent {
  func box(_ properties: DefaultProperties = DefaultProperties(), _ children: [Element]? = nil) -> Element {
    return ElementData(ElementType.box, properties, children)
  }

  func image(_ properties: ImageProperties) -> Element {
    return ElementData(ElementType.image, properties)
  }

  func text(_ properties: TextProperties) -> Element {
    return ElementData(ElementType.text, properties)
  }

  func textfield(_ properties: TextFieldProperties) -> Element {
    return ElementData(ElementType.textfield, properties)
  }

  func button(_ properties: ButtonProperties) -> Element {
    return ElementData(ElementType.button, properties)
  }

  func view(_ wrappedView: UIView, _ properties: DefaultProperties = DefaultProperties()) -> Element {
    return ElementData(ElementType.view(wrappedView), properties)
  }

  func component<T: Properties>(_ componentClass: AnyClass, _ properties: T) -> Element {
    return ElementData(ElementType.component(componentClass), properties)
  }
}
