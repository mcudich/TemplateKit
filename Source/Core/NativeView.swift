//
//  NativeView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct EventRecognizers {
  typealias Recognizer = (Selector, UIGestureRecognizer)
  var onTap: Recognizer?
  var onPress: Recognizer?
  var onDoubleTap: Recognizer?

  public init() {}
}

public protocol NativeView: View {
  associatedtype PropertiesType: Properties

  var properties: PropertiesType { get set }
  var eventRecognizers: EventRecognizers { get set }
  weak var eventTarget: AnyObject? { get set }

  init()

  func touchesBegan()
}
