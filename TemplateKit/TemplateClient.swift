import UIKit

public protocol NodeProvider {
  func nodeWithName(name: String) -> Node?
}

public enum TemplateFetchStrategy {
  case Local(NSBundle, String?);
  case Remote(NSURL);
}

public class TemplateClient {
  let provider: NodeProvider

  public init(fetchStrategy: TemplateFetchStrategy = .Local(NSBundle.mainBundle(), nil)) {
    switch fetchStrategy {
    case .Local(let bundle, let directory):
      provider = LocalXMLNodeProvider(bundle: bundle, directory: directory);
    case .Remote:
      fatalError("Not implemented yet.");
    }
  }
}

extension TemplateClient: NodeProvider {
  public func nodeWithName(name: String) -> Node? {
    return provider.nodeWithName(name)
  }
}