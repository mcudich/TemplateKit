import UIKit

typealias NodeDefinitionResultHandler = (Result<Template>) -> Void

class TemplateParser: Parser {
  typealias ParsedType = Template

  required init() {}

  func parse(data: Data) throws -> Template {
    return try Template(xml: data)
  }
}

public class TemplateService {
  public static let shared = TemplateService()

  let resourceService = ResourceService<TemplateParser>()

  private lazy var cache = [URL: Template]()

  public init() {}

  public func element(withLocation location: URL, properties: [String: Any] = [:]) throws -> Element {
    guard let element = try cache[location]?.makeElement(with: properties) else {
      throw TemplateKitError.missingTemplate("Template not found for \(location)")
    }
    return element
  }

  public func fetchTemplates(withURLs urls: [URL], completion: @escaping (Result<Void>) -> Void) {
    var expectedCount = urls.count
    for url in urls {
      resourceService.load(url) { [weak self] result in
        expectedCount -= 1
        switch result {
        case .success(let template):
          self?.cache[url] = template
          if expectedCount == 0 {
            completion(.success())
          }
        case .error(_):
          completion(.error(TemplateKitError.missingTemplate("Template not found at \(url)")))
        }
      }
    }
  }
}
