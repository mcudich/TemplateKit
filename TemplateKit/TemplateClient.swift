import UIKit

public protocol NodeProvider {
  func node(withName name: String, properties: [String: Any]?) -> Node?
}

public enum TemplateFetchStrategy {
  case local(Bundle, String?)
  case remote(URL)
}

public class TemplateClient {
  let provider: NodeProvider

  public init(fetchStrategy: TemplateFetchStrategy = .local(Bundle.main, nil)) {
    switch fetchStrategy {
    case .local(let bundle, let directory):
      provider = LocalXMLNodeProvider(bundle: bundle, directory: directory)
    case .remote:
      fatalError("Not implemented yet.")
    }
  }
}

extension TemplateClient: NodeProvider {
  public func node(withName name: String, properties: [String: Any]?) -> Node? {
    return provider.node(withName: name, properties: properties)
  }
}
