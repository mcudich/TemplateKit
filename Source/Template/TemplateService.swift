import UIKit

public protocol TemplateService {
  var templates: [URL: Template] { get }
  func fetchTemplates(withURLs urls: [URL], completion: @escaping (Result<Void>) -> Void)
  func addObserver(observer: Node, forLocation location: URL)
  func removeObserver(observer: Node, forLocation location: URL)
}
