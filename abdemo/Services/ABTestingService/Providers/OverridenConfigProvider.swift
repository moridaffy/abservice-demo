import Foundation

class OverriddenConfigProvider {
  private let storage: ABConfigStorage

  private weak var abTestingService: IABTestingService?

  private(set) var config: ABConfig?

  let priority: ABConfigProviderPriority = .top

  init(storage: ABConfigStorage,
       abTestingService: IABTestingService) {
    self.storage = storage
    self.abTestingService = abTestingService
  }

  func setOverriddenFlag(_ flag: ABConfig.Flag) {
    guard let config = config else {
      assertionFailure()
      return
    }

    let collection = config.collections.first ?? .init(name: "Overridden")
    if let index = collection.flags.firstIndex(where: { $0.key == flag.key }) {
      collection.flags[index] = flag
    } else {
      collection.flags.append(flag)
    }

    config.collections = [collection]
    storage.saveConfig(config, forKey: .cachedOverriddenConfig)
    self.config = config
  }
}

extension OverriddenConfigProvider: IABConfigProvider {
  func reset() {
    self.config = .empty
  }

  func fetchConfig(completion: @escaping (Error?) -> Void) {
    self.config = storage.getConfig(forKey: .cachedOverriddenConfig) ?? .empty
    completion(nil)
  }

  func getValue(for key: ABValueKey) -> Any? {
    guard abTestingService?.isOverridingEnabled == true else { return nil }

    return config?.collections
      .flatMap { $0.flags }
      .first(where: { $0.key == key.rawValue })?
      .value
  }
}
