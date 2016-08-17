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
    textStorage.setAttributedString(NSAttributedString(string: propertyProvider?.get("text") ?? "asdf"))
    textContainer.size = size;
    layoutManager.ensureLayout(for: textContainer)

    let measuredSize = layoutManager.usedRect(for: textContainer).size

    return CGSize(width: ceil(measuredSize.width), height: ceil(measuredSize.height))
  }
}

extension TextView: View {
  func render() -> UIView {
    setNeedsDisplay()
    return self
  }
}
