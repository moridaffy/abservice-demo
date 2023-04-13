import Foundation

class WWFRemoteProvider: WWFProvider {
  private enum Constants {
    static let cachedConfigKey: String = "cached_remote_config"
  }

  override var name: String { "Remote" }

  private let apiService: IAPIService
  private let logService: ILogService
  private let userDefaults: UserDefaults
  private let decoder: JSONDecoder
  private let encoder: JSONEncoder
  private let resolver: WWFConditionResolver

  init(apiService: IAPIService,
       logService: ILogService,
       userDefaults: UserDefaults,
       decoder: JSONDecoder,
       encoder: JSONEncoder,
       resolver: WWFConditionResolver) {
    self.apiService = apiService
    self.logService = logService
    self.userDefaults = userDefaults
    self.decoder = decoder
    self.encoder = encoder
    self.resolver = resolver

    super.init()

    fetchConfig()
  }

  override func getValue<Value>(forKey key: String) -> Value? {
    let value: Value? = super.getValue(forKey: key)
    logService.setIdentity(forKey: key, value: String(describing: value))
    return value
  }
}

private extension WWFRemoteProvider {
  func fetchConfig(completion: (() -> Void)? = nil) {
    fetchCachedConfig()
    fetchRemoteConfig(completion: completion)
  }

  func fetchRemoteConfig(completion: (() -> Void)? = nil) {
    apiService.fetchConfig { [weak self] result in
      if let self = self,
         case let .success(configuration) = result {
        self.setCachedConfig(configuration)
        self.values = configuration.parse(resolver: self.resolver)
      }

      completion?()
    }
  }

  func fetchCachedConfig() {
    guard let data = userDefaults.object(forKey: Constants.cachedConfigKey) as? Data,
          let configuration = try? decoder.decode(Configuration.self, from: data) else { return }
    self.values = configuration.parse(resolver: self.resolver)
  }

  func setCachedConfig(_ config: Configuration) {
    guard let data = try? encoder.encode(config) else { return }
    userDefaults.set(data, forKey: Constants.cachedConfigKey)
  }
}
