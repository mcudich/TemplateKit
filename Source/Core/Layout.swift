//
//  Layout.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

extension Node {
  public var flexDirection: CSSFlexDirection {
    return get("flexDirection") ?? CSSFlexDirectionColumn
  }

  public var direction: CSSDirection {
    return get("direction") ?? CSSDirectionLTR
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

  public func buildCSSNode() -> CSSNode {
    if let cssNode = cssNode {
      return cssNode
    }

    let newNode = CSSNode()

    switch self.element!.type {
    case ElementType.box:
      let childNodes: [CSSNode] = children?.map {
        return $0.buildCSSNode()
      } ?? []
      newNode.children = childNodes
    default:
      break
    }

    cssNode = newNode

    updateCSSNode()

    return cssNode!
  }

  public func updateCSSNode() {
    cssNode?.alignSelf = alignSelf
    cssNode?.flexGrow = flexGrow
    cssNode?.flexShrink = flexShrink
    cssNode?.margin = margin
    cssNode?.size = size
    cssNode?.minSize = minSize
    cssNode?.maxSize = maxSize
    cssNode?.position = position
    cssNode?.positionType = positionType

    switch self.element!.type {
    case ElementType.box:
      cssNode?.flexDirection = flexDirection
      cssNode?.direction = direction
      cssNode?.justifyContent = justifyContent
      cssNode?.alignContent = alignContent
      cssNode?.alignItems = alignItems
      cssNode?.flexWrap = flexWrap
      cssNode?.overflow = overflow
      cssNode?.padding = padding
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

      cssNode?.context = context
      cssNode?.measure = measure

      // If we're in this function, it's because properties have changed. If so, might as well
      // mark this node as dirty so it's certain to be visited.
      cssNode?.markDirty()
    default:
      break
    }
  }
}

extension Component {
  public func buildCSSNode() -> CSSNode {
    return instance.buildCSSNode()
  }

  public func updateCSSNode() {
    instance.updateCSSNode()
  }
}
