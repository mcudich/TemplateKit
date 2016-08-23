import UIKit

extension String {
  var textAlignment: NSTextAlignment? {
    switch self {
    case "left":
      return .left
    case "center":
      return .center
    case "right":
      return .right
    case "justified":
      return .justified
    case "natural":
      return .natural
    default:
      fatalError("Unhandled value")
    }
  }

  var lineBreakMode: NSLineBreakMode? {
    switch self {
    case "byWordWrapping":
      return .byWordWrapping
    case "byCharWrapping":
      return .byCharWrapping
    case "byClipping":
      return .byClipping
    case "byTruncatingHead":
      return .byTruncatingHead
    case "byTruncatingTail":
      return .byTruncatingTail
    case "byTruncatingMiddle":
      return .byTruncatingMiddle
    default:
      fatalError("Unhandled value")
    }
  }
}

enum TextValidation: String, ValidationType {
  case textAlignment
  case lineBreakMode

  func validate(value: Any?) -> Any? {
    switch self {
    case .textAlignment:
      if value is NSTextAlignment {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.textAlignment
      }
    case .lineBreakMode:
      if value is NSLineBreakMode {
        return value
      }
      if let stringValue = value as? String {
        return stringValue.lineBreakMode
      }
    }

    if value != nil {
      fatalError("Unhandled type!")
    }

    return nil
  }
}

class TextView: UILabel {
  var calculatedFrame: CGRect?
  weak var propertyProvider: PropertyProvider?

  fileprivate var fontName: String {
    return propertyProvider?.get("fontName") ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
  }

  fileprivate var fontSize: CGFloat {
    return propertyProvider?.get("fontSize") ?? UIFont.systemFontSize
  }

  fileprivate var color: UIColor {
    return propertyProvider?.get("textColor") ?? .black
  }

  private lazy var layoutManager: NSLayoutManager = {
    let layoutManager = NSLayoutManager();
    layoutManager.addTextContainer(self.textContainer);
    layoutManager.usesFontLeading = false;
    return layoutManager;
  }();

  fileprivate lazy var textStorage: NSTextStorage = {
    let textStorage = NSTextStorage();
    textStorage.addLayoutManager(self.layoutManager);
    return textStorage;
  }();

  private lazy var textContainer: NSTextContainer = {
    let textContainer = NSTextContainer();
    textContainer.lineFragmentPadding = 0;
    return textContainer;
  }();

  required init() {
    super.init(frame: CGRect.zero)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func drawText(in rect: CGRect) {
    let glyphRange = layoutManager.glyphRange(for: textContainer);

    layoutManager.drawBackground(forGlyphRange: glyphRange, at: CGPoint.zero);
    layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: CGPoint.zero);
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    applyProperties()
    textContainer.size = size;
    layoutManager.ensureLayout(for: textContainer)

    let measuredSize = layoutManager.usedRect(for: textContainer).size

    return CGSize(width: ceil(measuredSize.width), height: ceil(measuredSize.height))
  }

  private func applyProperties() {
    guard let font = UIFont(name: fontName, size: fontSize) else {
      fatalError("Attempting to use unknown font")
    }
    var attributes = [
      NSFontAttributeName: font,
      NSForegroundColorAttributeName: color
    ]

    let text = NSAttributedString(string: propertyProvider?.get("text") ?? "", attributes: attributes)
    textStorage.setAttributedString(text)

    textContainer.lineBreakMode = propertyProvider?.get("lineBreakMode") ?? .byTruncatingTail
  }
}

extension TextView: View {
  func render() -> UIView {
    setNeedsDisplay()
    return self
  }
}
