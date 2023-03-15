import Foundation

protocol IABTestingService: AnyObject {
  var isOverridingEnabled: Bool { get set }
  var localConfig: ABConfig? { get }

  func configure()
  func reset()

  func setOverriddenToggle(_ toggle: ABConfig.Toggle)

  func getStringValue(forKey key: ABValueKey) -> String?
  func getIntValue(forKey key: ABValueKey) -> Int?
  func getBoolValue(forKey key: ABValueKey) -> Bool?
  func getDecodableValue<T: Decodable>(forKey key: ABValueKey, type: T.Type) -> T?

  func getReadableValue(for toggle: ABConfig.Toggle) -> String?
}

class ABTestingService: IABTestingService {
  private enum Keys: String {
    case cachedConfigKey = "ab_cached_config"
    case cachedOverriddenConfigKey = "ab_cached_overridden_config"
    case overridingEnabled = "ab_overriding_enabled"
  }

  private var isConfigured: Bool = false

  private let userDefaults: UserDefaults
  private lazy var decoder = JSONDecoder()
  private lazy var encoder = JSONEncoder()

  private(set) var localConfig: ABConfig? {
    didSet {
      guard let config = localConfig,
            let data = try? encoder.encode(config) else {
        assertionFailure()
        return
      }
      userDefaults.set(data, forKey: Keys.cachedConfigKey.rawValue)
      userDefaults.synchronize()
    }
  }
  private var overriddenConfig: ABConfig? {
    didSet {
      guard let config = overriddenConfig,
            let data = try? encoder.encode(config) else {
        assertionFailure()
        return
      }
      userDefaults.set(data, forKey: Keys.cachedOverriddenConfigKey.rawValue)
      userDefaults.synchronize()
    }
  }

  var isOverridingEnabled: Bool {
    didSet {
      userDefaults.set(isOverridingEnabled, forKey: Keys.overridingEnabled.rawValue)
      userDefaults.synchronize()
    }
  }

  static let shared = ABTestingService()

  private init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults

    if ConstantHelper.buildType == .appStore {
      self.isOverridingEnabled = false
    } else {
      self.isOverridingEnabled = userDefaults.object(forKey: Keys.overridingEnabled.rawValue) as? Bool ?? false
    }
  }

  func configure() {
    if isConfigured { return }

    getLocalConfig()

    isConfigured = true
  }

  func reset() {
    overriddenConfig = .empty
  }

  func setOverriddenToggle(_ toggle: ABConfig.Toggle) {
    guard let localConfig = localConfig,
          let overriddenConfig = overriddenConfig,
          let collection = localConfig.collections.first(where: { collection in
            collection.toggles.contains(where: { $0.key == toggle.key })
          }) else {
      assertionFailure()
      return
    }

    if !overriddenConfig.collections.contains(where: { $0.name == collection.name }) {
      overriddenConfig.collections.append(.init(name: collection.name))
    }
    guard let overriddenCollectionIndex = overriddenConfig.collections.firstIndex(where: { $0.name == collection.name }) else {
      assertionFailure()
      return
    }

    if let overriddenToggleIndex = overriddenConfig.collections[overriddenCollectionIndex].toggles.firstIndex(where: { $0.key == toggle.key }) {
      overriddenConfig.collections[overriddenCollectionIndex].toggles[overriddenToggleIndex] = toggle
    } else {
      overriddenConfig.collections[overriddenCollectionIndex].toggles.append(toggle)
    }

    self.overriddenConfig = overriddenConfig
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
  func getLocalConfig() {
    if let data = userDefaults.object(forKey: Keys.cachedConfigKey.rawValue) as? Data,
       let config = try? decoder.decode(ABConfig.self, from: data) {
      self.localConfig = config
    } else if let url = Bundle.main.url(forResource: "offline_config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? decoder.decode(ABConfig.self, from: data) {
      self.localConfig = config
    } else {
      assertionFailure("Failed to get any local config")
    }

    if let data = userDefaults.object(forKey: Keys.cachedOverriddenConfigKey.rawValue) as? Data {
      do {
        let config = try decoder.decode(ABConfig.self, from: data)
        self.overriddenConfig = config
      } catch let error {
        self.overriddenConfig = .empty
      }
    }
  }

  func getRemoteConfig(completionHandler: () -> Void) {
    APIService.shared.fetchConfig { [weak self] config in
      guard let self = self else { return }

      guard let config = config else {
        // TODO: log error while trying to fetch actual AB config
        return
      }

      self.localConfig = config
    }
  }

  func getValue(forKey key: ABValueKey) -> Any? {
    guard isConfigured else { return nil }

    return getOverriddenValue(for: key) ?? getConfigValue(for: key)
  }

  func getOverriddenValue(for key: ABValueKey) -> Any? {
    guard isOverridingEnabled else { return nil }

    return overriddenConfig?.collections
      .flatMap { $0.toggles }
      .first(where: { $0.key == key.rawValue })?
      .value
  }

  func getConfigValue(for key: ABValueKey) -> Any? {
    let toggle = localConfig?.collections
      .flatMap { $0.toggles }
      .first(where: { $0.key == key.rawValue })
    guard let toggle = toggle else { return nil }

    guard let conditions = toggle.conditions,
          !conditions.isEmpty,
          let preConditionValue = toggle.preConditionValue,
          let afterConditionValue = toggle.afterConditionValue else {
      return toggle.value
    }

    return ABConditionResolver.resolve(conditions) ? afterConditionValue : preConditionValue
  }
}
