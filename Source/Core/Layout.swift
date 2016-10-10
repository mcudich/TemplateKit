//
//  Layout.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

public struct LayoutProperties: RawProperties, Model, Equatable {
  public var flexDirection: CSSFlexDirection?
  public var direction: CSSDirection?
  public var justifyContent: CSSJustify?
  public var alignContent: CSSAlign?
  public var alignItems: CSSAlign?
  public var alignSelf: CSSAlign?
  public var positionType: CSSPositionType?
  public var flexWrap: CSSWrapType?
  public var overflow: CSSOverflow?
  public var flexGrow: Float?
  public var flexShrink: Float?
  public var margin: Float?
  public var marginTop: Float?
  public var marginBottom: Float?
  public var marginLeft: Float?
  public var marginRight: Float?
  public var padding: Float?
  public var paddingTop: Float?
  public var paddingBottom: Float?
  public var paddingLeft: Float?
  public var paddingRight: Float?
  public var top: Float?
  public var bottom: Float?
  public var left: Float?
  public var right: Float?
  public var width: Float?
  public var height: Float?
  public var minWidth: Float?
  public var minHeight: Float?
  public var maxWidth: Float?
  public var maxHeight: Float?

  public var computedMargin: CSSEdges {
    return CSSEdges(left: marginLeft ?? margin ?? 0, right: marginRight ?? margin ?? 0, bottom: marginBottom ?? margin ?? 0, top: marginTop ?? margin ?? 0)
  }

  public var computedPadding: CSSEdges {
    return CSSEdges(left: paddingLeft ?? padding ?? 0, right: paddingRight ?? padding ?? 0, bottom: paddingBottom ?? padding ?? 0, top: paddingTop ?? padding ?? 0)
  }

  public var position: CSSEdges {
    return CSSEdges(left: left ?? 0, right: right ?? 0, bottom: bottom ?? 0, top: top ?? 0)
  }

  public var size: CSSSize {
    return CSSSize(width: width ?? .nan, height: height ?? .nan)
  }

  public var minSize: CSSSize? {
    if minWidth != nil || minHeight != nil {
      return CSSSize(width: minWidth ?? 0, height: minHeight ?? 0)
    }
    return nil
  }

  public var maxSize: CSSSize? {
    if maxWidth != nil || maxHeight != nil {
      return CSSSize(width: maxWidth ?? .greatestFiniteMagnitude, height: maxHeight ?? .greatestFiniteMagnitude)
    }
    return nil
  }

  public init() {}

  public init(_ properties: [String : Any]) {
    flexDirection = properties.cast("flexDirection")
    direction = properties.cast("direction")
    justifyContent = properties.cast("justifyContent")
    alignContent = properties.cast("alignContent")
    alignItems = properties.cast("alignItems")
    alignSelf = properties.cast("alignSelf")
    positionType = properties.cast("positionType")
    flexWrap = properties.cast("flexWrap")
    overflow = properties.cast("overflow")
    flexGrow = properties.cast("flexGrow")
    flexShrink = properties.cast("flexShrink")
    margin = properties.cast("margin")
    marginTop = properties.cast("marginTop")
    marginBottom = properties.cast("marginBottom")
    marginLeft = properties.cast("marginLeft")
    marginRight = properties.cast("marginRight")
    padding = properties.cast("padding")
    paddingTop = properties.cast("paddingTop")
    paddingBottom = properties.cast("paddingBottom")
    paddingLeft = properties.cast("paddingLeft")
    paddingRight = properties.cast("paddingRight")
    top = properties.cast("top")
    bottom = properties.cast("bottom")
    left = properties.cast("left")
    right = properties.cast("right")
    width = properties.cast("width")
    height = properties.cast("height")
    minWidth = properties.cast("minWidth")
    minHeight = properties.cast("minHeight")
    maxWidth = properties.cast("maxWidth")
    maxHeight = properties.cast("maxHeight")
  }

  public mutating func merge(_ other: LayoutProperties) {
    merge(&flexDirection, other.flexDirection)
    merge(&direction, other.direction)
    merge(&justifyContent, other.justifyContent)
    merge(&alignContent, other.alignContent)
    merge(&alignItems, other.alignItems)
    merge(&alignSelf, other.alignSelf)
    merge(&positionType, other.positionType)
    merge(&flexWrap, other.flexWrap)
    merge(&overflow, other.overflow)
    merge(&flexGrow, other.flexGrow)
    merge(&flexShrink, other.flexShrink)
    merge(&margin, other.margin)
    merge(&marginTop, other.marginTop)
    merge(&marginBottom, other.marginBottom)
    merge(&marginLeft, other.marginLeft)
    merge(&marginRight, other.marginRight)
    merge(&padding, other.padding)
    merge(&paddingTop, other.paddingTop)
    merge(&paddingBottom, other.paddingBottom)
    merge(&paddingLeft, other.paddingLeft)
    merge(&paddingRight, other.paddingRight)
    merge(&top, other.top)
    merge(&bottom, other.bottom)
    merge(&left, other.left)
    merge(&right, other.right)
    merge(&width, other.width)
    merge(&height, other.height)
    merge(&minWidth, other.minWidth)
    merge(&minHeight, other.minHeight)
    merge(&maxWidth, other.maxWidth)
    merge(&maxHeight, other.maxHeight)
  }
}

extension Float {
  func equals(_ other: Float?) -> Bool {
    guard let other = other else {
      return false
    }
    if isNaN && other.isNaN {
      return true
    }
    if self >= Float.greatestFiniteMagnitude && other >= Float.greatestFiniteMagnitude {
      return true
    }
    return self == other
  }
}

extension CSSSize {
  static func compare(_ lhs: CSSSize?, _ rhs: CSSSize?) -> Bool {
    if lhs == nil && rhs == nil {
      return true
    }
    guard let lhs = lhs, let rhs = rhs else {
      return false
    }

    return lhs.width.equals(rhs.width) && lhs.height.equals(rhs.height)
  }
}

public func ==(lhs: LayoutProperties, rhs: LayoutProperties) -> Bool {
  return lhs.flexDirection == rhs.flexDirection && lhs.direction == rhs.direction && lhs.justifyContent == rhs.justifyContent && lhs.alignContent == rhs.alignContent && lhs.alignItems == rhs.alignItems && lhs.alignSelf == rhs.alignSelf && lhs.positionType == rhs.positionType && lhs.flexWrap == rhs.flexWrap && lhs.overflow == rhs.overflow && lhs.flexGrow == rhs.flexGrow && lhs.flexShrink == rhs.flexShrink && lhs.margin == rhs.margin && lhs.padding == rhs.padding && CSSSize.compare(lhs.size, rhs.size) && lhs.minSize == rhs.minSize && lhs.maxSize == rhs.maxSize
}

extension PropertyNode where Self.PropertiesType: Properties {
  public var flexDirection: CSSFlexDirection {
    return properties.core.layout.flexDirection ?? CSSFlexDirectionColumn
  }

  public var direction: CSSDirection {
    return properties.core.layout.direction ?? CSSDirectionLTR
  }

  public var justifyContent: CSSJustify {
    return properties.core.layout.justifyContent ?? CSSJustifyFlexStart
  }

  public var alignContent: CSSAlign {
    return properties.core.layout.alignContent ?? CSSAlignStretch
  }

  public var alignItems: CSSAlign {
    return properties.core.layout.alignItems ?? CSSAlignStretch
  }

  public var alignSelf: CSSAlign {
    return properties.core.layout.alignSelf ?? CSSAlignAuto
  }

  public var positionType: CSSPositionType {
    return properties.core.layout.positionType ?? CSSPositionTypeRelative
  }

  public var flexWrap: CSSWrapType {
    return properties.core.layout.flexWrap ?? CSSWrapTypeNoWrap
  }

  public var overflow: CSSOverflow {
    return properties.core.layout.overflow ?? CSSOverflowVisible
  }

  public var flexGrow: Float {
    return properties.core.layout.flexGrow ?? 0
  }

  public var flexShrink: Float {
    return properties.core.layout.flexShrink ?? 0
  }

  public var margin: CSSEdges {
    return properties.core.layout.computedMargin
  }

  public var position: CSSEdges {
    return properties.core.layout.position
  }

  public var padding: CSSEdges {
    return properties.core.layout.computedPadding
  }

  public var size: CSSSize {
    return properties.core.layout.size
  }

  public var minSize: CSSSize? {
    return properties.core.layout.minSize
  }

  public var maxSize: CSSSize? {
    return properties.core.layout.maxSize
  }

  public func buildCSSNode() -> CSSNode {
    if cssNode == nil {
      cssNode = CSSNode()
    }

    switch self.element.type {
    case ElementType.box:
      let childNodes: [CSSNode] = children?.map {
        return $0.buildCSSNode()
      } ?? []
      cssNode?.children = childNodes
    default:
      break
    }

    updateCSSNode()

    return cssNode!
  }

  public func updateCSSNode() {
    cssNode?.alignSelf = alignSelf
    cssNode?.flexGrow = flexGrow
    cssNode?.flexShrink = flexShrink
    cssNode?.margin = margin
    cssNode?.size = size
    if let minSize = minSize {
      cssNode?.minSize = minSize
    }
    if let maxSize = maxSize {
      cssNode?.maxSize = maxSize
    }
    cssNode?.position = position
    cssNode?.positionType = positionType

    switch self.element.type {
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
      let textLayout = TextLayout(properties: properties as! TextProperties)
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

extension CompositeComponent {
  public func buildCSSNode() -> CSSNode {
    return instance.buildCSSNode()
  }

  public func updateCSSNode() {
    instance.updateCSSNode()
  }
}
