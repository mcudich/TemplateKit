//
//  Layout.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

public protocol Layoutable {
  func applyLayout(layout: CSSLayout)
}

public protocol View: Layoutable {
  var frame: CGRect { get set }
}

enum Layout {
  static func perform(_ element: Element) -> CSSLayout {
    return element.node.layout()
  }
}

extension Element {
  public var flexDirection: CSSFlexDirection {
    return get("flexDirection") ?? CSSFlexDirectionColumn
  }

  public var justifyContent: CSSJustify {
    return get("justifyContent") ?? CSSJustifyFlexStart
  }

  public var alignContent: CSSAlign {
    return get("alignContent") ?? CSSAlignStretch
  }

  public var alignItems: CSSAlign {
    return get("alignItems") ?? CSSAlignStretch
  }

  public var alignSelf: CSSAlign {
    return get("alignSelf") ?? CSSAlignAuto
  }

  public var positionType: CSSPositionType {
    return get("positionType") ?? CSSPositionTypeRelative
  }

  public var flexWrap: CSSWrapType {
    return get("flexWrap") ?? CSSWrapTypeNoWrap
  }

  public var overflow: CSSOverflow {
    return get("overflow") ?? CSSOverflowVisible
  }

  public var flexGrow: Float {
    return get("flexGrow") ?? 0
  }

  public var flexShrink: Float {
    return get("flexShrink") ?? 0
  }

  public var margin: CSSEdges {
    return CSSEdges(left: get("marginLeft") ?? 0, right: get("marginRight") ?? 0, bottom: get("marginBottom") ?? 0, top: get("marginTop") ?? 0)
  }

  public var position: CSSEdges {
    return CSSEdges(left: get("left") ?? 0, right: get("right") ?? 0, bottom: get("bottom") ?? 0, top: get("top") ?? 0)
  }

  public var padding: CSSEdges {
    return CSSEdges(left: get("paddingLeft") ?? 0, right: get("paddingRight") ?? 0, bottom: get("paddingBottom") ?? 0, top: get("paddingTop") ?? 0)
  }

  public var size: CSSSize {
    return CSSSize(width: get("width") ?? Float.nan, height: get("height") ?? Float.nan)
  }

  public var minSize: CSSSize {
    return CSSSize(width: get("minWidth") ?? 0, height: get("minHeight") ?? 0)
  }

  public var maxSize: CSSSize {
    return CSSSize(width: get("maxWidth") ?? Float.greatestFiniteMagnitude, height: get("maxHeight") ?? Float.greatestFiniteMagnitude)
  }

  var node: CSSNode {
    switch self.type {
    case ElementType.box:
      let childNodes = children?.map { $0.node } ?? []
      return CSSNode(flexDirection: flexDirection, justifyContent: justifyContent, alignContent: alignContent, alignItems: alignItems, alignSelf: alignSelf, positionType: positionType, flexWrap: flexWrap, overflow: overflow, flexGrow: flexGrow, flexShrink: flexShrink, margin: margin, position: position, padding: padding, size: size, minSize: minSize, maxSize: maxSize, children: childNodes)
    case ElementType.text:
      let textLayout = TextLayout()
      textLayout.properties = properties
      let context = UnsafeMutableRawPointer(Unmanaged.passRetained(textLayout).toOpaque())

      let measure: CSSMeasureFunc = { context, width, widthMode, height, heightMode in
        let effectiveWidth = width.isNaN ? Float.greatestFiniteMagnitude : width
        let textLayout = Unmanaged<TextLayout>.fromOpaque(context!).takeUnretainedValue()
        let size = textLayout.sizeThatFits(CGSize(width: CGFloat(effectiveWidth), height: CGFloat.greatestFiniteMagnitude))

        return CSSSize(width: Float(size.width), height: Float(size.height))
      }
      return CSSNode(alignSelf: alignSelf, flexGrow: flexGrow, margin: margin, size: size, measure: measure, context: context)
    default:
      return CSSNode(alignSelf: alignSelf, flexGrow: flexGrow, margin: margin, size: size)
    }
  }
}
