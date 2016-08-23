import UIKit

public protocol NodeProvider {
  func node(withName name: String, properties: [String: Any]?) -> Node?
}

public enum TemplateFetchStrategy {
  case local(Bundle, String?)
  case remote(URL)
}

public protocol TemplateClientDelegate: class {
  func templatesDidLoad()
  func templatesDidFailToLoad(withError error: Error)
}

protocol TemplateProvider: NodeProvider {
  func fetchTemplates(completion: @escaping (Result<Void>) -> Void)
}

public class TemplateClient {
  public weak var delegate: TemplateClientDelegate?
  fileprivate let provider: TemplateProvider

  public init(fetchStrategy: TemplateFetchStrategy = .local(Bundle.main, nil)) {
    switch fetchStrategy {
    case .local(let bundle, let directory):
      provider = LocalXMLNodeProvider(bundle: bundle, directory: directory)
    case .remote:
      fatalError("Not implemented yet.")
    }
  }

  public func fetchTemplates() {
    provider.fetchTemplates { [weak self] result in
      DispatchQueue.main.async {
        switch result {
        case .success(let result):
          self?.delegate?.templatesDidLoad()
        case .error(let error):
          self?.delegate?.templatesDidFailToLoad(withError: error)
        }
      }
    }
  }
}

extension TemplateClient: NodeProvider {
  public func node(withName name: String, properties: [String: Any]?) -> Node? {
    return provider.node(withName: name, properties: properties)
  }
}
