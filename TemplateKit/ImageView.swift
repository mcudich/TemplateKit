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
      if value is UIViewContentMode {
        return value
      }
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
