//
//  Text.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

class TextLayout {
  var textValue = ""
  var fontName = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
  var fontSize = UIFont.systemFontSize
  var color = UIColor.black
  var lineBreakModeValue = NSLineBreakMode.byTruncatingTail

  fileprivate lazy var layoutManager: NSLayoutManager = {
    let layoutManager = NSLayoutManager()
    layoutManager.addTextContainer(self.textContainer)
    layoutManager.usesFontLeading = false
    return layoutManager
  }()

  fileprivate lazy var textStorage: NSTextStorage = {
    let textStorage = NSTextStorage()
    textStorage.addLayoutManager(self.layoutManager)
    return textStorage
  }()

  fileprivate lazy var textContainer: NSTextContainer = {
    let textContainer = NSTextContainer()
    textContainer.lineFragmentPadding = 0
    return textContainer
  }()

  func sizeThatFits(_ size: CGSize) -> CGSize {
    applyProperties()
    textContainer.size = size;
    layoutManager.ensureLayout(for: textContainer)

    let measuredSize = layoutManager.usedRect(for: textContainer).size

    return CGSize(width: ceil(measuredSize.width), height: ceil(measuredSize.height))
  }

  fileprivate func drawText(in rect: CGRect) {
    let glyphRange = layoutManager.glyphRange(for: textContainer);

    layoutManager.drawBackground(forGlyphRange: glyphRange, at: CGPoint.zero);
    layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: CGPoint.zero);
  }

  private func applyProperties() {
    guard let fontValue = UIFont(name: fontName, size: fontSize) else {
      fatalError("Attempting to use unknown font")
    }
    let attributes: [String : Any] = [
      NSFontAttributeName: fontValue,
      NSForegroundColorAttributeName: color
    ]

    let text = NSAttributedString(string: textValue, attributes: attributes)
    textStorage.setAttributedString(text)

    textContainer.lineBreakMode = lineBreakModeValue
  }
}

public class TextView: UILabel {
  let textLayout: TextLayout

  init(textLayout: TextLayout) {
    self.textLayout = textLayout

    super.init(frame: CGRect.zero)

    isUserInteractionEnabled = true
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func drawText(in rect: CGRect) {
    textLayout.drawText(in: rect)
  }

  public override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
    super.addGestureRecognizer(gestureRecognizer)
  }
}

public class Text: LeafNode {
  public typealias View = TextView

  public var root: Node?
  public var renderedView: UIView?
  public let properties: [String: Any]
  public var state: Any?
  public var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  fileprivate var textLayout = TextLayout()

  public required init(properties: [String : Any]) {
    self.properties = properties
  }

  public func sizeThatFits(_ size: CGSize) -> CGSize {
    applyTextProperties()
    return textLayout.sizeThatFits(size)
  }

  public func buildView() -> UIView {
    let view = TextView(textLayout: textLayout)
    view.setNeedsDisplay()
    return view
  }

  public func applyProperties(to view: UIView) {
    applyTextProperties()
  }

  fileprivate func applyTextProperties() {
    if let text: String = get("text") {
      textLayout.textValue = text
    }
    if let fontName: String = get("fontName") {
      textLayout.fontName = fontName
    }
    if let fontSize: CGFloat = get("fontSize") {
      textLayout.fontSize = fontSize
    }
    if let color: UIColor = get("color") {
      textLayout.color = color
    }
    if let lineBreakMode: NSLineBreakMode = get("lineBreakMode") {
      textLayout.lineBreakModeValue = lineBreakMode
    }
  }
}

extension Text: Layoutable {
  public var flexNode: FlexNode {
    let measure: ((CGFloat) -> CGSize) = { width in
      let effectiveWidth = width.isNaN ? CGFloat.greatestFiniteMagnitude : width
      return self.sizeThatFits(CGSize(width: effectiveWidth, height: CGFloat.greatestFiniteMagnitude)) 
    }

    return FlexNode(size: flexSize, margin: margin, selfAlignment: selfAlignment, flex: flex, measure: measure)
  }
}
