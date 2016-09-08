//
//  Text.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class TextLayout {
  var text = ""
  var fontName = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
  var fontSize = UIFont.systemFontSize
  var color = UIColor.black
  var lineBreakMode = NSLineBreakMode.byTruncatingTail

  var properties = [String: Any]() {
    didSet {
      transferProperties()
    }
  }

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

  init() {}

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

  private func transferProperties() {
    if let text = properties["text"] as? String {
      self.text = text
    }
    if let fontName = properties["fontName"] as? String {
      self.fontName = fontName
    }
    if let fontSize = properties["fontSize"] as? CGFloat {
      self.fontSize = fontSize
    }
    if let lineBreakMode = properties["lineBreakMode"] as? NSLineBreakMode {
      self.lineBreakMode = lineBreakMode
    }
  }

  private func applyProperties() {
    guard let fontValue = UIFont(name: fontName, size: fontSize) else {
      fatalError("Attempting to use unknown font")
    }
    let attributes: [String : Any] = [
      NSFontAttributeName: fontValue,
      NSForegroundColorAttributeName: color
    ]

    textStorage.setAttributedString(NSAttributedString(string: text, attributes: attributes))

    textContainer.lineBreakMode = lineBreakMode
  }
}

public class Text: UILabel, NativeView {
  public var eventTarget: AnyObject?

  public var properties = [String : Any]() {
    didSet {
      applyCommonProperties(properties: properties)
      textLayout.properties = properties
      setNeedsDisplay()
    }
  }

  private lazy var textLayout = TextLayout()

  public required init() {
    super.init(frame: CGRect.zero)

    isUserInteractionEnabled = true

    applyCommonProperties(properties: properties)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func drawText(in rect: CGRect) {
    textLayout.drawText(in: rect)
  }
}
