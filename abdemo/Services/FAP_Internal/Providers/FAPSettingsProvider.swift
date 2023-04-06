import Foundation

class FAPSettingsProvider: FAPProvider {
  private enum Constants {
    static let cachedDebugKeyPrefix = "fap_settings_"
    static let cachedDebugListKey = "cached_settings_keys"
  }

  override var name: String { "Settings" }
  override var description: String { "User-specified settings" }
  override var isWritable: Bool { true }

  private let userDefaults: UserDefaults

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults

    super.init()

    fetchCachedValues()
  }

  override func setValue<Value>(_ value: Value?, forKey key: FAPKeyPath) -> Bool {
    guard super.setValue(value, forKey: key) else { return false }
    setCachedValue(forKey: key, value: value)
    return true
  }

  override func resetValue(forKey key: FAPKeyPath) {
    super.resetValue(forKey: key)
    resetCachedValue(forKey: key)
  }

  override func reset() {
    super.reset()
    resetCachedValues()
  }
}

private extension FAPSettingsProvider {
  func fetchCachedValues() {
    guard let keys = userDefaults.object(forKey: Constants.cachedDebugListKey) as? [String] else { return }

    for key in keys {
      guard let value = userDefaults.object(forKey: key) else { continue }

      let originalKey = key.dropFirst(Constants.cachedDebugKeyPrefix.count)
      guard let keyPath = FAPKeyPath(path: String(originalKey)) else { continue }
      values[keyPath] = value
    }
  }

  func setCachedValue(forKey key: FAPKeyPath, value: Any?) {
    let cachedKey = Constants.cachedDebugKeyPrefix + key.path

    userDefaults.set(value, forKey: cachedKey)

    var keys = userDefaults.object(forKey: Constants.cachedDebugListKey) as? [String] ?? []
    if !keys.contains(cachedKey) {
      keys.append(cachedKey)
    }
    userDefaults.set(keys, forKey: Constants.cachedDebugListKey)
  }

  func resetCachedValue(forKey key: FAPKeyPath) {
    let cachedKey = Constants.cachedDebugKeyPrefix + key.path

    userDefaults.removeObject(forKey: cachedKey)

    var keys = userDefaults.object(forKey: Constants.cachedDebugListKey) as? [String] ?? []
    if keys.contains(cachedKey) {
      keys.removeAll(where: { $0 == cachedKey })
    }
    userDefaults.set(keys, forKey: Constants.cachedDebugListKey)
  }

  func resetCachedValues() {
    if let keys = userDefaults.object(forKey: Constants.cachedDebugListKey) as? [String] {
      for key in keys {
        userDefaults.removeObject(forKey: key)
      }
    }
    userDefaults.removeObject(forKey: Constants.cachedDebugListKey)
  }
}
