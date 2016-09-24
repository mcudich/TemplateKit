//
//  Image.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct ImageProperties: ViewProperties {
  public var key: String?
  public var layout = LayoutProperties()
  public var style = StyleProperties()
  public var gestures = GestureProperties()

  public var contentMode = UIViewContentMode.scaleAspectFit
  public var url: URL?
  public var name: String?

  public init() {}

  public init(_ properties: [String : Any]) {
    applyProperties(properties)

    if let contentMode: UIViewContentMode = properties.cast("contentMode") {
      self.contentMode = contentMode
    }
    url = properties.cast("url")
    name = properties.cast("name")
  }
}

public func ==(lhs: ImageProperties, rhs: ImageProperties) -> Bool {
  return lhs.contentMode == rhs.contentMode && lhs.url == rhs.url && lhs.name == rhs.name && lhs.equals(otherViewProperties: rhs)
}

public class Image: UIImageView, NativeView {
  public weak var eventTarget: AnyObject?

  public var properties = ImageProperties([:]) {
    didSet {
      applyProperties()
    }
  }

  public required init() {
    super.init(frame: CGRect.zero)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func applyProperties() {
    applyCommonProperties()
    applyImageProperties()
  }

  func applyImageProperties() {
    contentMode = properties.contentMode

    if let url = properties.url {
      ImageService.shared.load(url) { [weak self] result in
        switch result {
        case .success(let image):
          DispatchQueue.main.async {
            self?.image = image
          }
        case .failure(_):
          // TODO(mcudich): Show placeholder error image.
          break
        }
      }
    } else if let name = properties.name {
      image = UIImage(named: name)
    }
  }
}
