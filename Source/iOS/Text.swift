//
//  Text.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class TextLayout {
  var properties: TextProperties

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

  init(properties: TextProperties) {
    self.properties = properties
  }

  func sizeThatFits(_ size: CGSize) -> CGSize {
    applyProperties()
    textContainer.size = size;
    layoutManager.ensureLayout(for: textContainer)

    let measuredSize = layoutManager.usedRect(for: textContainer).size

    return CGSize(width: ceil(measuredSize.width), height: ceil(measuredSize.height))
  }

  fileprivate func drawText(in rect: CGRect) {
    applyProperties()
    let glyphRange = layoutManager.glyphRange(for: textContainer);

    layoutManager.drawBackground(forGlyphRange: glyphRange, at: CGPoint.zero);
    layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: CGPoint.zero);
  }

  private func applyProperties() {
    guard let fontValue = UIFont(name: properties.textStyle.fontName, size: properties.textStyle.fontSize) else {
      fatalError("Attempting to use unknown font")
    }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = properties.textStyle.textAlignment

    let attributes: [String : Any] = [
      NSFontAttributeName: fontValue,
      NSForegroundColorAttributeName: properties.textStyle.color,
      NSParagraphStyleAttributeName: paragraphStyle
    ]

    textStorage.setAttributedString(NSAttributedString(string: properties.textStyle.text, attributes: attributes))

    textContainer.lineBreakMode = properties.textStyle.lineBreakMode
  }
}

public struct TextStyleProperties: RawPropertiesReceiver, Equatable {
  public var text = ""
  public var fontName = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
  public var fontSize = UIFont.systemFontSize
  public var color = UIColor.black
  public var lineBreakMode = NSLineBreakMode.byTruncatingTail
  public var textAlignment = NSTextAlignment.natural

  public init(_ properties: [String : Any]) {
    if let text: String = properties.cast("text") {
      self.text = text
    }
    if let fontName: String = properties.cast("fontName") {
      self.fontName = fontName
    }
    if let fontSize: CGFloat = properties.cast("fontSize") {
      self.fontSize = fontSize
    }
    if let color: UIColor = properties.color("color") {
      self.color = color
    }
    if let lineBreakMode: NSLineBreakMode = properties.cast("lineBreakMode") {
      self.lineBreakMode = lineBreakMode
    }
    if let textAlignment: NSTextAlignment = properties.cast("textAlignment") {
      self.textAlignment = textAlignment
    }
  }
}

public func ==(lhs: TextStyleProperties, rhs: TextStyleProperties) -> Bool {
  return lhs.text == rhs.text && lhs.fontName == rhs.fontName && lhs.fontSize == rhs.fontSize && lhs.color == rhs.color && lhs.lineBreakMode == rhs.lineBreakMode && lhs.textAlignment == rhs.textAlignment
}

public struct TextProperties: ViewProperties {
  public var key: String?
  public var layout: LayoutProperties?
  public var style: StyleProperties?
  public var gestures: GestureProperties?

  public var textStyle = TextStyleProperties([:])

  public init(_ properties: [String : Any]) {
    applyProperties(properties)
    textStyle = TextStyleProperties(properties)
  }
}

public func ==(lhs: TextProperties, rhs: TextProperties) -> Bool {
  return lhs.textStyle == rhs.textStyle && lhs.equals(otherViewProperties: rhs)
}

public class Text: UILabel, NativeView {
  public weak var eventTarget: AnyObject?

  public var properties = TextProperties([:]) {
    didSet {
      applyCommonProperties()
      textLayout.properties = properties
      setNeedsDisplay()
    }
  }

  private lazy var textLayout: TextLayout = {
    return TextLayout(properties: self.properties)
  }()

  public required init() {
    super.init(frame: CGRect.zero)

    isUserInteractionEnabled = true

    applyCommonProperties()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func drawText(in rect: CGRect) {
    textLayout.drawText(in: rect)
  }
}
