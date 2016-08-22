//
//  ImageView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

enum ImageValidation: String, ValidationType {
  case contentMode

  func validate(value: Any?) -> Any? {
    switch self {
    case .contentMode:
      if let stringValue = value as? String {
        return stringValue.contentMode
      }
    }

    if value != nil {
      fatalError("Unhandled type!")
    }

    return nil
  }
}

extension String {
  var contentMode: UIViewContentMode? {
    switch self {
      case "scaleToFill":
        return .scaleToFill
      case "scaleAspectFit":
        return .scaleAspectFit
      case "scaleAspectFill":
        return .scaleAspectFill
      default:
        fatalError("Unhandled value")
    }
  }
}

class ImageView: UIImageView {
  var calculatedFrame: CGRect?
  weak var propertyProvider: PropertyProvider?

  var url: URL? {
    return propertyProvider?.get("url")
  }

  var name: String? {
    return propertyProvider?.get("name")
  }

  required init() {
    super.init(frame: CGRect.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate func load() {
    if let url = url {
      ImageService.shared.loadImage(withURL: url) { [weak self] image in
        self?.image = image
      }
    } else if let name = name {
      image = UIImage(named: name)
    }
  }
}

extension ImageView: View {
  func render() -> UIView {
    load()
    self.contentMode = propertyProvider?.get("contentMode") ?? .scaleToFill
    return self
  }
}
