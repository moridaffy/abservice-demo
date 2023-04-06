import Foundation

class FAPDebugProvider: FAPProvider {
  private enum Constants {
    static let cachedDebugKeyPrefix = "fap_debug_"
    static let cachedDebugListKey = "cached_debug_keys"
  }

  override var name: String { "Debug" }
  override var description: String { "Overriding any existing values" }
  override var isWritable: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
  }

  private let userDefaults: UserDefaults

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults

    super.init()

    fetchCachedValues()
//    imitateUpdates()
  }

  @discardableResult
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

private extension FAPDebugProvider {
  func fetchCachedValues() {
    guard let keys = userDefaults.object(forKey: Constants.cachedDebugListKey) as? [String] else { return }

    for key in keys {
      guard let value = userDefaults.object(forKey: key) else { continue }

      let originalKey = key.dropFirst(Constants.cachedDebugKeyPrefix.count)
      guard let keyPath = FAPKeyPath(path: String(originalKey)) else { continue }
      setValue(value, forKey: keyPath)
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

  func imitateUpdates() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
      guard let self = self else { return }
      let value = ["B80000", "DB3E00", "FCCB00", "008B02", "006B76", "1273DE", "004DCF", "5300EB", "EB9694", "FAD0C3", "FEF3BD", "C1E1C5", "BEDADC", "C4DEF6", "D4C4FB"].randomElement() ?? "000000"
      self.setValue(value, forKey: FAPKeyPath.Main.backgroundColor.keyPath)
      self.imitateUpdates()
    }
  }
}
