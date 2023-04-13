import Foundation

class WWFDebugProvider: WWFProvider {
  private enum Constants {
    static let cachedDebugKeyPrefix = "wwf_debug_"
    static let cachedDebugListKey = "cached_debug_keys"
  }

  override var name: String { "Debug" }

  private let userDefaults: UserDefaults

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults

    super.init()

    fetchCachedValues()
    imitateUpdates()
  }
}

private extension WWFDebugProvider {
  func fetchCachedValues() {
    guard let keys = userDefaults.object(forKey: Constants.cachedDebugListKey) as? [String] else { return }

    for key in keys {
      guard let value = userDefaults.object(forKey: key) else { continue }

      let originalKey = key.dropFirst(Constants.cachedDebugKeyPrefix.count)
      setValue(value, forKey: String(originalKey))
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

  func imitateUpdates() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self = self else { return }
      let value = ["B80000", "DB3E00", "FCCB00", "008B02", "006B76", "1273DE", "004DCF", "5300EB", "EB9694", "FAD0C3", "FEF3BD", "C1E1C5", "BEDADC", "C4DEF6", "D4C4FB"].randomElement() ?? "000000"
      self.setValue(value, forKey: "ab_main_background_color")
      self.imitateUpdates()
    }
  }
}

extension WWFDebugProvider: WWFISettableProvider {
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

extension WWFDebugProvider: WWFIResettableProvider {
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
