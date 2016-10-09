//
//  Image.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct ImageProperties: Properties {
  public var core = CoreProperties()

  public var contentMode: UIViewContentMode?
  public var url: URL?
  public var name: String?
  public var image: UIImage?

  public init() {}

  public init(_ properties: [String : Any]) {
    core = CoreProperties(properties)

    contentMode = properties.cast("contentMode")
    url = properties.cast("url")
    name = properties.cast("name")
    image = properties.image("image")
  }

  public mutating func merge(_ other: ImageProperties) {
    core.merge(other.core)

    merge(&contentMode, other.contentMode)
    merge(&url, other.url)
    merge(&name, other.name)
    merge(&image, other.image)
  }
}

public func ==(lhs: ImageProperties, rhs: ImageProperties) -> Bool {
  return lhs.contentMode == rhs.contentMode && lhs.url == rhs.url && lhs.name == rhs.name && lhs.equals(otherProperties: rhs)
}

public class Image: UIImageView, NativeView {
  public weak var eventTarget: AnyObject?
  public lazy var eventRecognizers = [AnyObject]()

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
    applyCoreProperties()
    applyImageProperties()
  }

  func applyImageProperties() {
    contentMode = properties.contentMode ?? .scaleAspectFit

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
      self.image = UIImage(named: name)
    } else if let image = properties.image {
      self.image = image
    }
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    touchesBegan()
  }
}
