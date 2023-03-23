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
    let flag = config?.collections
      .flatMap { $0.flags }
      .first(where: { $0.key == key.rawValue })
    guard let flag = flag else { return nil }

    if let conditions = flag.conditions {
      return ABConditionResolver.resolve(conditions) ? flag.conditionTrueValue : flag.conditionFalseValue
    } else {
      return flag.value
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
