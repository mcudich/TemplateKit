import UIKit

class TextView: UILabel {
  var calculatedFrame: CGRect?
  weak var propertyProvider: PropertyProvider?

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

  required init() {
    super.init(frame: CGRectZero)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func drawTextInRect(rect: CGRect) {
    let glyphRange = layoutManager.glyphRangeForTextContainer(textContainer);

    layoutManager.drawBackgroundForGlyphRange(glyphRange, atPoint: CGPointZero);
    layoutManager.drawGlyphsForGlyphRange(glyphRange, atPoint: CGPointZero);
  }

  override func sizeThatFits(size: CGSize) -> CGSize {
    textStorage.setAttributedString(NSAttributedString(string: propertyProvider?.get("text") ?? "asdf"))
    textContainer.size = size;
    layoutManager.ensureLayoutForTextContainer(textContainer)

    let measuredSize = layoutManager.usedRectForTextContainer(textContainer).size

    return CGSize(width: ceil(measuredSize.width), height: ceil(measuredSize.height))
  }
}

extension TextView: View {
  static var propertyTypes: [String : Validator] {
    return [
      "text": Validation.string()
    ]
  }

  func render() -> UIView {
    setNeedsDisplay()
    return self
  }
}