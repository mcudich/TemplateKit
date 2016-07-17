import UIKit

public class TextNode: Node {
  public var text: String? {
    didSet {
      if let text = text {
        textStorage.setAttributedString(NSAttributedString(string: text))
      }
    }
  }

  private lazy var textView: TextView = {
    return TextView(layoutManager: self.layoutManager, textContainer: self.textContainer, textStorage: self.textStorage);
  }()

  private lazy var layoutManager: NSLayoutManager = {
    let layoutManager = NSLayoutManager();
    layoutManager.addTextContainer(self.textContainer);
    layoutManager.usesFontLeading = false;
    return layoutManager;
  }();

  private lazy var textStorage: NSTextStorage = {
    let textStorage = NSTextStorage();
    textStorage.addLayoutManager(self.layoutManager);
    return textStorage;
  }();

  private lazy var textContainer: NSTextContainer = {
    let textContainer = NSTextContainer();
    textContainer.lineFragmentPadding = 0;
    return textContainer;
  }();

  override public func measure(size: CGSize) -> CGSize {
    textContainer.size = size;
    layoutManager.ensureLayoutForTextContainer(textContainer)

    let measuredSize = layoutManager.usedRectForTextContainer(textContainer).size

    return CGSize(width: ceil(measuredSize.width), height: ceil(measuredSize.height))
  }

  public override func render() -> UIView {
    let view = super.render()

    textView.setNeedsDisplay()

    return view
  }

  override func applyProperties() {
    super.applyProperties()

    if let textValue = properties["text"] {
      text = resolve(textValue)
    }
  }

  override func createView() -> UIView {
    return textView
  }
}

class TextView: UILabel {
  private let layoutManager: NSLayoutManager;
  private let textContainer: NSTextContainer;
  private let textStorage: NSTextStorage;

  init(layoutManager: NSLayoutManager, textContainer: NSTextContainer, textStorage: NSTextStorage) {
    self.layoutManager = layoutManager;
    self.textContainer = textContainer;
    self.textStorage = textStorage;

    super.init(frame: CGRectZero);
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func drawTextInRect(rect: CGRect) {
    let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer);

    layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: CGPointZero);
    layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: CGPointZero);
  }
}