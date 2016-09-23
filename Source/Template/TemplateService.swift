import UIKit

public protocol TemplateService {
  func element(withLocation location: URL, properties: Properties) throws -> Element
  func fetchTemplates(withURLs urls: [URL], completion: @escaping (Result<Void>) -> Void)
  func addObserver(observer: Node, forLocation location: URL)
  func removeObserver(observer: Node, forLocation location: URL)
}


