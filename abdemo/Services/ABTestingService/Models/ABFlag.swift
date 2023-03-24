import Foundation

@propertyWrapper class ABFlag<T: Codable> {
  private let key: ABValueKey
  private let fallbackValue: T?

  private weak var abService: IABTestingService?
  private weak var logService: ILogService?

  var wrappedValue: T? {
    get {
      guard let value = getValue(forKey: key) else { return nil }
      (self.logService ?? LogService.shared)?.setIdentity(identity: key.rawValue, value: value)
      return value
    }
    set {
      (self.abService ?? ABTestingService.shared).setOverriddenFlag(forKey: key, value: newValue)
    }
  }

  init(key: ABValueKey,
       fallbackValue: T? = nil,
       abService: IABTestingService? = nil,
       logService: ILogService? = nil) {
    self.key = key
    self.fallbackValue = fallbackValue
    self.abService = abService
  }
}

private extension ABFlag {
  func getValue(forKey key: ABValueKey) -> T? {
    guard let rawValue = (self.abService ?? ABTestingService.shared).getValue(forKey: key) else { return nil }

    if let value = rawValue as? T {
      return value
    } else if let dictionary = rawValue as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let value = try? JSONDecoder().decode(T.self, from: data) {
      return value
    } else {
      return fallbackValue
    }
  }
}
