import Foundation

class WWFRootCollection: WWFICollection {
  static let shared = WWFRootCollection()

  private(set) var providers: [WWFIProvider] = []
  private var subscribers: [AnyWrapper: ((WWFRootCollection) -> Void)] = [:]
  private weak var observer: WWFIProviderObserver?

  var main: WWFMainCollection { __main }
  var _main: WWFCollection<WWFMainCollection> { ___main }
  @WWFCollection(key: "main")
  private var __main: WWFMainCollection

  var map: WWFMapCollection { __map }
  var _map: WWFCollection<WWFMapCollection> { ___map }
  @WWFCollection(key: "map")
  private var __map: WWFMapCollection

  required init() {
    self.configure(with: Self.defaultProviders)
  }

  func subscribe(_ subscriber: AnyHashable, block: @escaping (WWFRootCollection) -> Void) {
    let subscriber = AnyWrapper(subscriber)
    subscribers[subscriber] = block
    block(self)
  }
}



private extension WWFRootCollection {
  static var defaultProviders: [WWFIProvider] = {
    let userDefaults = UserDefaults.standard
    let apiService = APIService.shared
    let logService = LogService.shared
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let resolver = WWFConditionResolver.shared

    return [
      WWFDebugProvider(userDefaults: userDefaults),
      WWFSettingsProvider(userDefaults: userDefaults),
      WWFRemoteProvider(apiService: apiService,
                        logService: logService,
                        userDefaults: userDefaults,
                        decoder: decoder,
                        encoder: encoder,
                        resolver: resolver),
      WWFLocalProvider(decoder: decoder,
                       resolver: resolver)
    ]
  }()
}

extension WWFRootCollection: WWFIConfigurableWithProviders {
  func configure(with providers: [WWFIProvider]) {
    self.providers = providers

    Mirror(reflecting: self).children.lazy.forEach { child in
      let value = child.value
      if let configurable = child.value as? WWFIConfigurableWithProviders {
        configurable.configure(with: providers)
      }
      if let observable = value as? WWFIObservable {
        observable.addObserver(self)
      }
    }
  }
}

extension WWFRootCollection: WWFIProviderObserver {
  func didChangeValue(key: String?) {
    subscribers.forEach { $0.value(self) }
  }
}

extension WWFRootCollection: WWFIObservable {
  func addObserver(_ observer: WWFIProviderObserver, forKey key: String?) {
    if self.observer != nil {
      assertionFailure()
    }

    self.observer = observer
    observer.didChangeValue(key: key)
  }

  func removeObserver(_ observer: WWFIProviderObserver) {
    guard self.observer == nil else {
      assertionFailure()
      return
    }

    self.observer = nil
  }
}
