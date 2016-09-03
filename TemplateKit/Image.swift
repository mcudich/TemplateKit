//
//  Image.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/2/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public class Image: LeafNode {
  public var root: Node?
  public var renderedView: UIView?
  public let properties: [String: Any]
  public var state: Any?
  public var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  public required init(properties: [String : Any]) {
    self.properties = properties
  }

  public func buildView() -> UIView {
    return UIImageView()
  }

  public func applyProperties(to view: UIView) {
    guard let view = view as? UIImageView else {
      return
    }

    if let url: URL = get("url") {
      load(url, view)
    } else if let name: String = get("name") {
      load(name, view)
    }

    view.contentMode = get("contentMode") ?? .scaleAspectFill
  }

  private func load(_ url: URL, _ view: UIImageView) {
    ImageService.shared.load(url) { result in
      switch result {
      case .success(let image):
        DispatchQueue.main.async {
          view.image = image
        }
      case .error(_):
        // TODO(mcudich): Show placeholder error image.
        break
      }
    }
  }

  private func load(_ name: String, _ view: UIImageView) {
    view.image = UIImage(named: name)
  }
}

extension Image: Layoutable {
}
