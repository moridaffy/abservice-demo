import Foundation

protocol IABTestingService: AnyObject {
  var isOverridingEnabled: Bool { get set }
  var localConfig: ABConfig? { get }

  func configure()
  func reset()

  func addObserver(_ observer: IABTestingServiceObserver)
  func removeObserver(_ observer: IABTestingServiceObserver)

  func setOverriddenToggle(_ toggle: ABConfig.Toggle)

  func getStringValue(forKey key: ABValueKey) -> String?
  func getIntValue(forKey key: ABValueKey) -> Int?
  func getBoolValue(forKey key: ABValueKey) -> Bool?
  func getDecodableValue<T: Decodable>(forKey key: ABValueKey, type: T.Type) -> T?

  func getReadableValue(for toggle: ABConfig.Toggle) -> String?
}

protocol IABTestingServiceObserver: Observer {
  func didChangeConfig(_ service: IABTestingService)
}

class ABTestingService: IABTestingService {
  private enum Keys {
    static let overridingEnabled: String = "ab_overriding_enabled"
  }

  private let configStorage: ABConfigStorage

  private var isConfigured: Bool = false
  private var providers: [IABConfigProvider] = []
  private var observers: [AnyObserver] = []

  private var overriddenProvider: OverriddenConfigProvider? {
    for provider in providers {
      if let provider = provider as? OverriddenConfigProvider {
        return provider
      }
    }
    return nil
  }

  var localConfig: ABConfig? {
    for provider in providers {
      if let provider = provider as? DefaultConfigProvider {
        return provider.config
      }
    }
    return nil
  }

  var isOverridingEnabled: Bool {
    didSet {
      configStorage.userDefaults.set(isOverridingEnabled, forKey: Keys.overridingEnabled)
      configStorage.userDefaults.synchronize()
      notifyObservers()
    }
  }

  static let shared = ABTestingService()

  private init(userDefaults: UserDefaults = .standard,
               encoder: JSONEncoder = JSONEncoder(),
               decoder: JSONDecoder = JSONDecoder()) {
    self.configStorage = ABConfigStorage(userDefaults: userDefaults,
                                         encoder: encoder,
                                         decoder: decoder)

    if ConstantHelper.buildType == .appStore {
      self.isOverridingEnabled = false
    } else {
      self.isOverridingEnabled = userDefaults.object(forKey: Keys.overridingEnabled) as? Bool ?? false
    }
  }

  func configure() {
    if isConfigured { return }

    providers = [
      OverriddenConfigProvider(storage: self.configStorage, abTestingService: self),
      RemoteConfigProvider(apiService: .shared, storage: self.configStorage),
      DefaultConfigProvider(decoder: self.configStorage.decoder)
    ]
      .sorted(by: { $0.priority > $1.priority })

    let group = DispatchGroup()
    group.notify(queue: .main) {
      self.isConfigured = true
      self.notifyObservers()
    }

    for provider in providers {
      group.enter()

      provider.fetchConfig { _ in
        group.leave()
      }
    }
  }

  func reset() {
    providers.forEach { $0.reset() }
  }

  func addObserver(_ observer: IABTestingServiceObserver) {
    if self.observers.contains(where: { $0.observer === observer }) { return }
    observer.didChangeConfig(self)
    self.observers.append(.init(observer))
  }

  func removeObserver(_ observer: IABTestingServiceObserver) {
    guard let index = self.observers.firstIndex(where: { $0.observer === observer }) else { return }
    self.observers.remove(at: index)
  }

  func setOverriddenToggle(_ toggle: ABConfig.Toggle) {
    overriddenProvider?.setOverriddenToggle(toggle)
    notifyObservers()
  }

  func getStringValue(forKey key: ABValueKey) -> String? {
    guard key.valueType == .string else {
      assertionFailure("Requesting AB value with wrong type for key `\(key.rawValue)`")
      return nil
    }
    return getValue(forKey: key) as? String
  }

  func getIntValue(forKey key: ABValueKey) -> Int? {
    guard key.valueType == .int else {
      assertionFailure("Requesting AB value with wrong type for key `\(key.rawValue)`")
      return nil
    }
    return getValue(forKey: key) as? Int
  }

  func getBoolValue(forKey key: ABValueKey) -> Bool? {
    guard key.valueType == .bool else {
      assertionFailure("Requesting AB value with wrong type for key `\(key.rawValue)`")
      return nil
    }
    return getValue(forKey: key) as? Bool
  }

  func getDecodableValue<T: Decodable>(forKey key: ABValueKey, type: T.Type) -> T? {
    guard case let .model(type) = key.valueType,
          type is T.Type else {
      assertionFailure("Requesting AB value with wrong type for key `\(key.rawValue)`")
      return nil
    }
    return getValue(forKey: key) as? T
  }

  func getReadableValue(for toggle: ABConfig.Toggle) -> String? {
    guard let valueKey = toggle.valueKey else {
      assertionFailure()
      return nil
    }

    switch valueKey.valueType {
    case .string:
      let stringValue = getStringValue(forKey: valueKey)?.nilIfEmpty
      if let stringValue = stringValue {
        return stringValue
      } else {
        return "nil"
      }

    case .bool:
      var boolValue: Bool?
      if valueKey == .overridingEnabled {
        boolValue = isOverridingEnabled
      } else {
        boolValue = getBoolValue(forKey: valueKey)
      }
      guard let boolValue = boolValue else {
        return "nil"
      }
      return boolValue ? "true" : "false"

    case .int:
      guard let intValue = getIntValue(forKey: valueKey) else {
        return "nil"
      }
      return "\(intValue)"

    case let .model(type):
      guard let value = getDecodableValue(forKey: valueKey, type: type) else {
        return "nil"
      }

      guard let data = try? JSONEncoder().encode(value),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
            let prettyString = String(data: prettyData, encoding: .utf8) else { return nil }

      return prettyString
    }
  }
}

private extension ABTestingService {
  func getValue(forKey key: ABValueKey) -> Any? {
    guard isConfigured else { return nil }

    for provider in providers {
      if let value = provider.getValue(for: key) {
        return value
      }
    }

    return nil
  }

  func notifyObservers() {
    self.observers.forEach { observer in
      if let observer = observer.observer as? IABTestingServiceObserver {
        observer.didChangeConfig(self)
      }
    }
  }
}
