import Foundation

@propertyWrapper class ABFlag<T: Codable> {
  private let key: ABValueKey
  private let fallbackValue: T?

  private weak var service: IABTestingService?

  var wrappedValue: T? {
    get {
      guard let value = getValue(forKey: self.key) else { return nil }
      return value as? T ?? getCodableValue(value) ?? fallbackValue
    }
    set {
      (self.service ?? ABTestingService.shared)
        .setOverriddenFlag(forKey: key, value: newValue)
    }
  }

  init(key: ABValueKey, fallbackValue: T? = nil, service: IABTestingService? = nil) {
    self.key = key
    self.fallbackValue = fallbackValue
    self.service = service
  }
}

private extension ABFlag {
  func getValue(forKey key: ABValueKey) -> Any? {
    (self.service ?? ABTestingService.shared)
      .getValue(forKey: key)
  }

  func getCodableValue(_ value: Any) -> T? {
    guard let dictionary = value as? [String: Any] else { return nil }

    do {
      let data = try JSONSerialization.data(withJSONObject: dictionary)
      let model = try JSONDecoder().decode(T.self, from: data)
      return model
    } catch let error {
      print("error: \(error.localizedDescription)")
      return nil
    }
  }
}
