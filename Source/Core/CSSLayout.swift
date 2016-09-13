//
//  CSSNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

public struct CSSEdges {
  let left: Float
  let right: Float
  let bottom: Float
  let top: Float

  public init(left: Float = 0, right: Float = 0, bottom: Float = 0, top: Float = 0) {
    self.left = left
    self.right = right
    self.bottom = bottom
    self.top = top
  }

  func apply(_ ref: CSSNodeRef, _ applyEdge: (CSSNodeRef, CSSEdge, Float) -> Void) {
    applyEdge(ref, CSSEdgeLeft, left)
    applyEdge(ref, CSSEdgeRight, right)
    applyEdge(ref, CSSEdgeTop, top)
    applyEdge(ref, CSSEdgeBottom, bottom)
  }
}

public struct CSSLayout {
  let frame: CGRect
  let children: [CSSLayout]

  init(nodeRef: CSSNodeRef) {
    let x = CGFloat(CSSNodeLayoutGetLeft(nodeRef))
    let y = CGFloat(CSSNodeLayoutGetTop(nodeRef))
    let width = CGFloat(CSSNodeLayoutGetWidth(nodeRef))
    let height = CGFloat(CSSNodeLayoutGetHeight(nodeRef))

    let children: [CSSLayout] = (0..<CSSNodeChildCount(nodeRef)).map {
      guard let childRef = CSSNodeGetChild(nodeRef, UInt32($0)) else {
        fatalError()
      }
      return CSSLayout(nodeRef: childRef)
    }

    self.frame = CGRect(x: x, y: y, width: width, height: height)
    self.children = children
  }

  func apply(to view: UIView) {
    view.frame = frame

    for (index, child) in children.enumerated() {
      child.apply(to: view.subviews[index])
    }
  }
}

public struct CSSNode {
  let direction: CSSDirection
  let flexDirection: CSSFlexDirection
  let justifyContent: CSSJustify
  let alignContent: CSSAlign
  let alignItems: CSSAlign
  let alignSelf: CSSAlign
  let positionType: CSSPositionType
  let flexWrap: CSSWrapType
  let overflow: CSSOverflow
  let flexGrow: Float
  let flexShrink: Float
  let margin: CSSEdges
  let position: CSSEdges
  let padding: CSSEdges
  let size: CSSSize
  let minSize: CSSSize
  let maxSize: CSSSize
  let measure: CSSMeasureFunc?
  let context: UnsafeMutableRawPointer?
  let children: [CSSNode]

  var nodeRef: CSSNodeRef {
    guard let nodeRef = CSSNodeNew() else {
      fatalError()
    }
    CSSNodeStyleSetDirection(nodeRef, direction)
    CSSNodeStyleSetFlexDirection(nodeRef, flexDirection)
    CSSNodeStyleSetJustifyContent(nodeRef, justifyContent)
    CSSNodeStyleSetAlignContent(nodeRef, alignContent)
    CSSNodeStyleSetAlignItems(nodeRef, alignItems)
    CSSNodeStyleSetAlignSelf(nodeRef, alignSelf)
    CSSNodeStyleSetPositionType(nodeRef, positionType)
    CSSNodeStyleSetFlexWrap(nodeRef, flexWrap)
    CSSNodeStyleSetOverflow(nodeRef, overflow)
    CSSNodeStyleSetFlexGrow(nodeRef, flexGrow)
    CSSNodeStyleSetFlexShrink(nodeRef, flexShrink)
    CSSNodeStyleSetWidth(nodeRef, size.width)
    CSSNodeStyleSetHeight(nodeRef, size.height)
    CSSNodeStyleSetMinWidth(nodeRef, minSize.width)
    CSSNodeStyleSetMinHeight(nodeRef, minSize.height)
    CSSNodeStyleSetMaxWidth(nodeRef, maxSize.width)
    CSSNodeStyleSetMaxHeight(nodeRef, maxSize.height)
    if let measure = measure {
      CSSNodeSetMeasureFunc(nodeRef, measure)
    }
    if let context = context {
      CSSNodeSetContext(nodeRef, context)
    }
    margin.apply(nodeRef, CSSNodeStyleSetMargin)
    position.apply(nodeRef, CSSNodeStyleSetPosition)
    padding.apply(nodeRef, CSSNodeStyleSetPadding)

    for (index, child) in children.enumerated() {
      CSSNodeInsertChild(nodeRef, child.nodeRef, UInt32(index))
    }

    return nodeRef
  }

  init(direction: CSSDirection = CSSDirectionLTR, flexDirection: CSSFlexDirection = CSSFlexDirectionColumn, justifyContent: CSSJustify = CSSJustifyFlexStart, alignContent: CSSAlign = CSSAlignAuto, alignItems: CSSAlign = CSSAlignStretch, alignSelf: CSSAlign = CSSAlignStretch, positionType: CSSPositionType = CSSPositionTypeRelative, flexWrap: CSSWrapType = CSSWrapTypeNoWrap, overflow: CSSOverflow = CSSOverflowVisible, flexGrow: Float = 0, flexShrink: Float = 0, margin: CSSEdges = CSSEdges(), position: CSSEdges = CSSEdges(), padding: CSSEdges = CSSEdges(), size: CSSSize = CSSSize(width: Float.nan, height: Float.nan), minSize: CSSSize = CSSSize(width: 0, height: 0), maxSize: CSSSize = CSSSize(width: Float.greatestFiniteMagnitude, height: Float.greatestFiniteMagnitude), measure: CSSMeasureFunc? = nil, context: UnsafeMutableRawPointer? = nil, children: [CSSNode] = []) {
    self.direction = direction
    self.flexDirection = flexDirection
    self.justifyContent = justifyContent
    self.alignContent = alignContent
    self.alignItems = alignItems
    self.alignSelf = alignSelf
    self.positionType = positionType
    self.flexWrap = flexWrap
    self.overflow = overflow
    self.flexGrow = flexGrow
    self.flexShrink = flexShrink
    self.margin = margin
    self.position = position
    self.padding = padding
    self.size = size
    self.minSize = minSize
    self.maxSize = maxSize
    self.measure = measure
    self.context = context
    self.children = children
  }

  func insertChild(child: CSSNode, at index: Int) {
    CSSNodeInsertChild(nodeRef, child.nodeRef, UInt32(index))
  }

  func layout(availableWidth: Float = Float.nan, availableHeight: Float = Float.nan) -> CSSLayout {
    let instance = nodeRef

    CSSNodeCalculateLayout(instance, availableWidth, availableHeight, CSSDirectionLTR)

    return CSSLayout(nodeRef: instance)
  }
}
