import UIKit

public protocol NodeProvider {
  func nodeWithId(id: String) -> Node?
}

public enum TemplateFetchStrategy {
  // The bundle and directory path in which to search for matching component definitions.
  case Local(NSBundle, String?);
  // TODO(mcudich): Consider what sort of parameters may be needed for remotely fetching
  // a component definition. Is a base URL enough here, and we figure out the rest?
  case Remote;
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