import Foundation

class FAPSettingsProvider: FAPProvider {
  private enum Constants {
    static let cachedDebugKeyPrefix = "fap_settings_"
    static let cachedDebugListKey = "cached_settings_keys"
  }

  override var name: String { "Settings" }

  private let userDefaults: UserDefaults

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults

    super.init()

    fetchCachedValues()
  }
}

private extension FAPSettingsProvider {
  func fetchCachedValues() {
    guard let keys = userDefaults.object(forKey: Constants.cachedDebugListKey) as? [String] else { return }

    for key in keys {
      guard let value = userDefaults.object(forKey: key) else { continue }

      let originalKey = key.dropFirst(Constants.cachedDebugKeyPrefix.count)
      values[String(originalKey)] = value
    }
  }

  func setCachedValue(forKey key: String, value: Any?) {
    let cachedKey = Constants.cachedDebugKeyPrefix + key

    userDefaults.set(value, forKey: cachedKey)

    var keys = userDefaults.object(forKey: Constants.cachedDebugListKey) as? [String] ?? []
    if !keys.contains(cachedKey) {
      keys.append(cachedKey)
    }
    userDefaults.set(keys, forKey: Constants.cachedDebugListKey)
  }

  func resetCachedValue(forKey key: String) {
    let cachedKey = Constants.cachedDebugKeyPrefix + key

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

extension FAPSettingsProvider: FAPISettableProvider {
  @discardableResult
  func setValue<Value>(_ value: Value?, forKey key: String) -> Bool {
    self.values[key] = value

    // TODO: придумать, как определять, изменилось ли значение
    let hasChanged = true
    if hasChanged {
      notifyObservers(keys: [key])
    }
    setCachedValue(forKey: key, value: value)

    return true
  }
}

extension FAPSettingsProvider: FAPIResettableProvider {
  func reset() {
    let keys = values.compactMap { $0.key }
    values.removeAll()
    notifyObservers(keys: keys)
    resetCachedValues()
  }

  func resetValue(forKey key: String) {
    let valueExisted = values[key] != nil
    values.removeValue(forKey: key)

    if valueExisted {
      notifyObservers(keys: [key])
    }
    resetCachedValue(forKey: key)
  }
}
