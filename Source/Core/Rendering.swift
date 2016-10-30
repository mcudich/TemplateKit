//
//  Rendering.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public func box(_ properties: DefaultProperties = DefaultProperties(), _ children: [Element]? = nil) -> Element {
  return ElementData(ElementType.box, properties, children)
}

public func image(_ properties: ImageProperties) -> Element {
  return ElementData(ElementType.image, properties)
}

public func text(_ properties: TextProperties) -> Element {
  return ElementData(ElementType.text, properties)
}

public func textfield(_ properties: TextFieldProperties) -> Element {
  return ElementData(ElementType.textfield, properties)
}

public func button(_ properties: ButtonProperties) -> Element {
  return ElementData(ElementType.button, properties)
}

public func table(_ properties: TableProperties) -> Element {
  return ElementData(ElementType.table, properties)
}

public func wrappedView(_ wrappedView: UIView, _ properties: DefaultProperties = DefaultProperties()) -> Element {
  return ElementData(ElementType.view(wrappedView), properties)
}

public func component<T: Properties>(_ componentClass: ComponentCreation.Type, _ properties: T) -> Element {
  return ElementData(ElementType.component(componentClass), properties)
}
