//
//  Image.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class Image: UIImageView, NativeView {
  public static var propertyTypes: [String: ValidationType] {
    return commonPropertyTypes.merged(with: [
      "url": Validation.url,
      "name": Validation.string,
      "contentMode": ImageValidation.contentMode
    ])
  }

  public var eventTarget: AnyObject?

  public var properties = [String : Any]() {
    didSet {
      applyCommonProperties(properties: properties)
      applyImageProperties(properties: properties)
    }
  }

  public required init() {
    super.init(frame: CGRect.zero)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func applyImageProperties(properties: [String: Any]) {
    contentMode = get("contentMode") ?? .scaleToFill

    if let url: URL = get("url") {
      ImageService.shared.load(url) { [weak self] result in
        switch result {
        case .success(let image):
          DispatchQueue.main.async {
            self?.image = image
          }
        case .error(_):
          // TODO(mcudich): Show placeholder error image.
          break
        }
      }
    } else if let name: String = get("name") {
      image = UIImage(named: name)
    }
  }
}
