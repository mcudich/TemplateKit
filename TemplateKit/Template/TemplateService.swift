import UIKit

public protocol TemplateService {
  func element(withLocation location: URL, properties: [String: Any]) throws -> Element
  func fetchTemplates(withURLs urls: [URL], completion: @escaping (Result<Void>) -> Void)
}


