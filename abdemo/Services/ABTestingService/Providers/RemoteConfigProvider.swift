import Foundation

class RemoteConfigProvider {
  private let apiService: APIService
  private let storage: ABConfigStorage

  private(set) var config: ABConfig?

  let priority: ABConfigProviderPriority = .medium

  init(apiService: APIService,
       storage: ABConfigStorage) {
    self.apiService = apiService
    self.storage = storage
  }
}

extension RemoteConfigProvider: IABConfigProvider {
  func fetchConfig(completion: @escaping (Error?) -> Void) {
    config = storage.getConfig(forKey: .cachedRemoteConfig)

    fetchRemoteConfig { [weak self] result in
      switch result {
      case .success(let config):
        self?.storage.saveConfig(config, forKey: .cachedRemoteConfig)
        self?.config = config
        completion(nil)

      case .failure(let error):
        completion(error)
      }
    }
  }

  func getValue(for key: ABValueKey) -> Any? {
    let toggle = config?.collections
      .flatMap { $0.toggles }
      .first(where: { $0.key == key.rawValue })
    guard let toggle = toggle else { return nil }

    if let conditions = toggle.conditions {
      return ABConditionResolver.resolve(conditions) ? toggle.preConditionValue : toggle.afterConditionValue
    } else {
      return toggle.value
    }
  }
}

private extension RemoteConfigProvider {
  func fetchRemoteConfig(completion: @escaping (Result<ABConfig, Error>) -> Void) {
    apiService.fetchConfig { config in
      if let config = config {
        completion(.success(config))
      } else {
        completion(.failure(NSError(domain: "network", code: 0)))
      }
    }
  }
}
