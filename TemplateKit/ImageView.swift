//
//  ImageView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class ImageView: UIImageView {
  var calculatedFrame: CGRect?
  weak var propertyProvider: PropertyProvider?

  var url: NSURL? {
    return propertyProvider?.get("url")
  }

  required init() {
    super.init(frame: CGRectZero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func load() {
    guard let url = url else { return }

    ImageService.shared.loadImageWithURL(url) { [weak self] image in
      self?.image = image
    }
  }
}

extension ImageView: View {
  static var propertyTypes: [String : Validator] {
    return [
      "url": Validation.url()
    ]
  }

  func render() -> UIView {
    load()
    return self
  }
}