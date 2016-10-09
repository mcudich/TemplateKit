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
    textContainer.size = rect.size
    let glyphRange = layoutManager.glyphRange(for: textContainer);

    layoutManager.drawBackground(forGlyphRange: glyphRange, at: CGPoint.zero);
    layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: CGPoint.zero);
  }

  private func applyProperties() {
    let fontName = properties.textStyle.fontName ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
    let fontSize = properties.textStyle.fontSize ?? UIFont.systemFontSize

    guard let fontValue = UIFont(name: fontName, size: fontSize) else {
      fatalError("Attempting to use unknown font")
    }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = properties.textStyle.textAlignment ?? .natural

    let attributes: [String : Any] = [
      NSFontAttributeName: fontValue,
      NSForegroundColorAttributeName: properties.textStyle.color ?? .black,
      NSParagraphStyleAttributeName: paragraphStyle
    ]

    textStorage.setAttributedString(NSAttributedString(string: properties.text ?? "", attributes: attributes))

    textContainer.lineBreakMode = properties.textStyle.lineBreakMode ?? .byTruncatingTail
  }
}

public struct TextProperties: Properties, InheritingProperties {
  public var core = CoreProperties()

  public var textStyle = TextStyleProperties()
  public var text: String?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)
    textStyle = TextStyleProperties(properties)
    text = properties.cast("text")
  }

  public mutating func merge(_ other: TextProperties) {
    core.merge(other.core)
    textStyle.merge(other.textStyle)
    merge(&text, other.text)
  }
}

public func ==(lhs: TextProperties, rhs: TextProperties) -> Bool {
  return lhs.text == rhs.text && lhs.textStyle == rhs.textStyle && lhs.equals(otherProperties: rhs)
}

public class Text: UILabel, NativeView {
  public weak var eventTarget: AnyObject?
  public lazy var eventRecognizers = [AnyObject]()

  public var properties = TextProperties() {
    didSet {
      applyCoreProperties()
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

    applyCoreProperties()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func drawText(in rect: CGRect) {
    textLayout.drawText(in: rect)
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    touchesBegan()
  }
}
