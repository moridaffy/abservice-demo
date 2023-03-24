import Foundation

class ABConfigStorage {
  let userDefaults: UserDefaults
  let encoder: JSONEncoder
  let decoder: JSONDecoder

  init(userDefaults: UserDefaults = .standard,
       encoder: JSONEncoder = JSONEncoder(),
       decoder: JSONDecoder = JSONDecoder()) {
    self.userDefaults = userDefaults
    self.encoder = encoder
    self.decoder = decoder
  }

  func saveConfig(_ config: ABConfig?, forKey key: Key) {
    guard let config = config,
          let data = try? encoder.encode(config) else {
      assertionFailure()
      return
    }

    userDefaults.set(data, forKey: key.rawValue)
    userDefaults.synchronize()
  }

  func getConfig(forKey key: Key) -> ABConfig? {
    guard let data = userDefaults.object(forKey: key.rawValue) as? Data,
          let config = try? decoder.decode(ABConfig.self, from: data) else {
      return nil
    }

    return config
  }
}

extension ABConfigStorage {
  enum Key: String {
    case cachedRemoteConfig = "ab_cached_config"
    case cachedOverriddenConfig = "ab_cached_overridden_config"
  }
}
