import Foundation

class FAPLocalProvider: FAPProvider {
  override var name: String { "Local" }
  override var description: String { "Locally-stored static values" }
  override var isWritable: Bool { false }

  private let decoder: JSONDecoder
  private let resolver: FAPConditionResolver

  init(decoder: JSONDecoder = JSONDecoder(),
       resolver: FAPConditionResolver = .shared) {
    self.decoder = decoder
    self.resolver = resolver

    super.init()

    fetchConfig()
  }

  override func setValue<Value>(_ value: Value?, forKey key: FAPKeyPath) -> Bool { false }
  override func resetValue(forKey key: FAPKeyPath) { }
  override func reset() { }
}

private extension FAPLocalProvider {
  func fetchConfig(completion: ((Error?) -> Void)? = nil) {
    guard let url = Bundle.main.url(forResource: "config", withExtension: "json") else {
      assertionFailure("Local config file missing")
      return
    }

    do {
      let data = try Data(contentsOf: url)
      let config = try decoder.decode(Configuration.self, from: data)
      self.values = config.parse(resolver: self.resolver)
      completion?(nil)
    } catch let error {
      completion?(error)
    }
  }
}
