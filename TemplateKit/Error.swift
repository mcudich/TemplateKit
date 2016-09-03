//
//  Error.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/23/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

enum TemplateKitError: Error {
  case parserError(String)
  case missingTemplate(String)
  case missingProvider(String)
  case missingPropertyTypes(String)
}
