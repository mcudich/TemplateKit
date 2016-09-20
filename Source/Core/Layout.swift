//
//  Layout.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

public struct LayoutProperties: RawPropertiesReceiver, Equatable {
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
  public var margin: CSSEdges?
  public var position: CSSEdges?
  public var padding: CSSEdges?
  public var size: CSSSize?
  public var minSize: CSSSize?
  public var maxSize: CSSSize?

  public init(_ properties: [String : Any]) {
    flexDirection = properties.get("flexDirection")
    direction = properties.get("direction")
    justifyContent = properties.get("justifyContent")
    alignContent = properties.get("alignContent")
    alignItems = properties.get("alignItems")
    alignSelf = properties.get("alignSelf")
    positionType = properties.get("positionType")
    flexWrap = properties.get("flexWrap")
    overflow = properties.get("overflow")
    flexGrow = properties.get("flexGrow")
    flexShrink = properties.get("flexShrink")
    margin = getEdges(properties: properties, prefix: "margin")
    padding = getEdges(properties: properties, prefix: "padding")
    size = getSize(properties: properties, widthKey: "width", heightKey: "height", defaultValue: Float.nan)
    minSize = getSize(properties: properties, widthKey: "minWidth", heightKey: "minHeight", defaultValue: Float.nan)
    maxSize = getSize(properties: properties, widthKey: "maxWidth", heightKey: "maxHeight", defaultValue: Float.greatestFiniteMagnitude)
  }

  private func getEdges(properties: [String: Any], prefix: String) -> CSSEdges {
    return CSSEdges(left: properties.get(prefix + "Left") ?? 0, right: properties.get(prefix + "Right") ?? 0, bottom: properties.get(prefix + "Bottom") ?? 0, top: properties.get(prefix + "Top") ?? 0)
  }

  private func getSize(properties: [String: Any], widthKey: String, heightKey: String, defaultValue: Float) -> CSSSize {
    return CSSSize(width: properties.get(widthKey) ?? defaultValue, height: properties.get(heightKey) ?? defaultValue)
  }
}

public func ==(lhs: LayoutProperties, rhs: LayoutProperties) -> Bool {
  return lhs.flexDirection == rhs.flexDirection && lhs.direction == rhs.direction && lhs.justifyContent == rhs.justifyContent && lhs.alignContent == rhs.alignContent && lhs.alignItems == rhs.alignItems && lhs.alignSelf == rhs.alignSelf && lhs.positionType == rhs.positionType && lhs.flexWrap == rhs.flexWrap && lhs.overflow == rhs.overflow && lhs.flexGrow == rhs.flexGrow && lhs.flexShrink == rhs.flexShrink && lhs.margin == rhs.margin && (lhs.padding == rhs.padding) && lhs.size == rhs.size && lhs.minSize == rhs.minSize && lhs.maxSize == rhs.maxSize
}

extension PropertyNode where Self.PropertiesType: ViewProperties {
  public var flexDirection: CSSFlexDirection {
    return properties.layout?.flexDirection ?? CSSFlexDirectionColumn
  }

  public var direction: CSSDirection {
    return properties.layout?.direction ?? CSSDirectionLTR
  }

  public var justifyContent: CSSJustify {
    return properties.layout?.justifyContent ?? CSSJustifyFlexStart
  }

  public var alignContent: CSSAlign {
    return properties.layout?.alignContent ?? CSSAlignStretch
  }

  public var alignItems: CSSAlign {
    return properties.layout?.alignItems ?? CSSAlignStretch
  }

  public var alignSelf: CSSAlign {
    return properties.layout?.alignSelf ?? CSSAlignAuto
  }

  public var positionType: CSSPositionType {
    return properties.layout?.positionType ?? CSSPositionTypeRelative
  }

  public var flexWrap: CSSWrapType {
    return properties.layout?.flexWrap ?? CSSWrapTypeNoWrap
  }

  public var overflow: CSSOverflow {
    return properties.layout?.overflow ?? CSSOverflowVisible
  }

  public var flexGrow: Float {
    return properties.layout?.flexGrow ?? 0
  }

  public var flexShrink: Float {
    return properties.layout?.flexShrink ?? 0
  }

  public var margin: CSSEdges {
    return properties.layout?.margin ?? CSSEdges()
  }

  public var position: CSSEdges {
    return properties.layout?.position ?? CSSEdges()
  }

  public var padding: CSSEdges {
    return properties.layout?.padding ?? CSSEdges()
  }

  public var size: CSSSize {
    return properties.layout?.size ?? CSSSize()
  }

  public var minSize: CSSSize {
    return properties.layout?.minSize ?? CSSSize()
  }

  public var maxSize: CSSSize {
    return properties.layout?.maxSize ?? CSSSize()
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
    cssNode?.minSize = minSize
    cssNode?.maxSize = maxSize
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

extension Component {
  public func buildCSSNode() -> CSSNode {
    return instance.buildCSSNode()
  }

  public func updateCSSNode() {
    instance.updateCSSNode()
  }
}
