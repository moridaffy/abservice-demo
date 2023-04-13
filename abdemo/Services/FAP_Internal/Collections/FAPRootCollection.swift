import Foundation

class FAPRootCollection: FAPICollection {
  static let shared = FAPRootCollection()

  private(set) var providers: [FAPIProvider] = []
  private var subscribers: [AnyWrapper: ((FAPRootCollection) -> Void)] = [:]
  private weak var observer: FAPIProviderObserver?

  var main: FAPMainCollection { __main }
  var _main: FAPCollection<FAPMainCollection> { ___main }
  @FAPCollection(key: "main")
  private var __main: FAPMainCollection

  var map: FAPMapCollection { __map }
  var _map: FAPCollection<FAPMapCollection> { ___map }
  @FAPCollection(key: "map")
  private var __map: FAPMapCollection

  required init() {
    self.configure(with: Self.defaultProviders)
  }

  func subscribe(_ subscriber: AnyHashable, block: @escaping (FAPRootCollection) -> Void) {
    let subscriber = AnyWrapper(subscriber)
    subscribers[subscriber] = block
    block(self)
  }
}



private extension FAPRootCollection {
  static var defaultProviders: [FAPIProvider] = {
    let userDefaults = UserDefaults.standard
    let apiService = APIService.shared
    let logService = LogService.shared
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let resolver = FAPConditionResolver.shared

    return [
      FAPDebugProvider(userDefaults: userDefaults),
      FAPSettingsProvider(userDefaults: userDefaults),
      FAPRemoteProvider(apiService: apiService,
                        logService: logService,
                        userDefaults: userDefaults,
                        decoder: decoder,
                        encoder: encoder,
                        resolver: resolver),
      FAPLocalProvider(decoder: decoder,
                       resolver: resolver)
    ]
  }()
}

extension FAPRootCollection: FAPIConfigurableWithProviders {
  func configure(with providers: [FAPIProvider]) {
    self.providers = providers

    Mirror(reflecting: self).children.lazy.forEach { child in
      let value = child.value
      if let configurable = child.value as? FAPIConfigurableWithProviders {
        configurable.configure(with: providers)
      }
      if let observable = value as? FAPIObservable {
        observable.addObserver(self)
      }
    }
  }
}

extension FAPRootCollection: FAPIProviderObserver {
  func didChangeValue(key: String?) {
    subscribers.forEach { $0.value(self) }
  }
}

extension FAPRootCollection: FAPIObservable {
  func addObserver(_ observer: FAPIProviderObserver, forKey key: String?) {
    if self.observer != nil {
      assertionFailure()
    }

    self.observer = observer
    observer.didChangeValue(key: key)
  }

  func removeObserver(_ observer: FAPIProviderObserver) {
    guard self.observer == nil else {
      assertionFailure()
      return
    }

    self.observer = nil
  }
}
