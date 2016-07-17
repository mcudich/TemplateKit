import UIKit
import AEXML

class LocalXMLNodeProvider {
  private lazy var definitions = [String: NodeDefinition]()

  private let bundle: NSBundle
  private let directory: String?

  init(bundle: NSBundle, directory: String?) {
    self.bundle = bundle
    self.directory = directory

    loadTemplates()
  }

  private func loadTemplates() {
    if let urls = bundle.URLsForResourcesWithExtension("xml", subdirectory: directory) {
      for url in urls {
        loadTemplate(url)
      }
    }
  }

  private func loadTemplate(url: NSURL) {
    let name = url.lastPathComponent!.componentsSeparatedByString(".").first!
    if let xml = NSData(contentsOfURL: url), definition = Template.process(xml) {
      definitions[name] = definition
    }
  }
}

extension LocalXMLNodeProvider: NodeProvider {
  func nodeWithName(name: String) -> Node? {
    return definitions[name]?.provideNode()
  }
}