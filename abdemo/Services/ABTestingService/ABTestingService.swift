import Foundation

protocol IABTestingService: AnyObject {
  var isOverridingEnabled: Bool { get set }
  var localConfig: ABConfig? { get }

  var abMainBackgroundColor: String? { get }
  var abMainShowLogo: Bool? { get }
  var abMainText: ABMainTextConfig? { get }

  var abCommonBadgeCount: Int? { get }

  func configure()
  func reset()

  func addObserver(_ observer: IABTestingServiceObserver, for keys: [ABValueKey])
  func removeObserver(_ observer: IABTestingServiceObserver)

  func setOverriddenFlag(forKey key: ABValueKey, value: Any?)

  func getValue(forKey key: ABValueKey) -> Any?
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
  private var observers: [AnyObserver: [ABValueKey]] = [:]

  private var overriddenProvider: OverriddenConfigProvider? {
    for provider in providers {
      if let provider = provider as? OverriddenConfigProvider {
        return provider
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

  var localConfig: ABConfig? {
    for provider in providers {
      if let provider = provider as? DefaultConfigProvider {
        return provider.config
      }
    }
    return nil
  }

  @ABFlag(key: .mainBackgroundColor)
  var abMainBackgroundColor: String?

  @ABFlag(key: .mainShowLogo)
  var abMainShowLogo: Bool?

  @ABFlag(key: .mainText)
  var abMainText: ABMainTextConfig?

  @ABFlag(key: .badgeCount)
  var abCommonBadgeCount: Int?

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
    isOverridingEnabled = false
  }

  func addObserver(_ observer: IABTestingServiceObserver, for keys: [ABValueKey]) {
    if self.observers.contains(where: { $0.key.observer === observer }) { return }
    observer.didChangeConfig(self)
    self.observers[.init(observer)] = keys
  }

  func removeObserver(_ observer: IABTestingServiceObserver) {
    if let observer = self.observers.first(where: { $0.key.observer === observer })?.key {
      self.observers.removeValue(forKey: observer)
    }
  }

  func setOverriddenFlag(forKey key: ABValueKey, value: Any?) {
    overriddenProvider?.setOverriddenFlag(.init(key: key.rawValue, description: nil, value: value))
    notifyObservers(for: key)
  }

  func getValue(forKey key: ABValueKey) -> Any? {
    guard isConfigured else { return nil }

    for provider in providers {
      if let value = provider.getValue(for: key) {
        return value
      }
    }

    return nil
  }
}

private extension ABTestingService {
  func notifyObservers(for key: ABValueKey? = nil) {
    var observers = self.observers
    if let key = key {
      observers = observers.filter { $0.value.contains(key) }
    }

    observers.forEach { ($0.key.observer as? IABTestingServiceObserver)?.didChangeConfig(self) }
  }
}
