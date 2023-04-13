import Foundation

// MARK: - Protocols

protocol FAPICollection {
  var providers: [FAPIProvider] { get }

  init()
}

protocol FAPIParentCollection {
  var subCollection: FAPICollection? { get }
}

// MARK: - FAPCollection

@propertyWrapper
class FAPCollection<Collection: FAPICollection>: Identifiable {
  let id: UUID = UUID()

  var wrappedValue: Collection

  private var key: String?

  private(set) var providers: [FAPIProvider] = []
  private var subscribers: [AnyWrapper: ((Collection) -> Void)] = [:]
  private weak var observer: FAPIProviderObserver?

  init(key: String) {
    self.key = key

    self.wrappedValue = Collection()
  }

  func subscribe(_ subscriber: AnyHashable, block: @escaping (Collection) -> Void) {
    let subscriber = AnyWrapper(subscriber)
    subscribers[subscriber] = block
    block(wrappedValue)
  }
}

extension FAPCollection: FAPIConfigurableWithProviders {
  func configure(with providers: [FAPIProvider]) {
    self.providers = providers

    Mirror(reflecting: wrappedValue).children.lazy.forEach { child in
      let value = child.value
      if let configurable = value as? FAPIConfigurableWithProviders {
        configurable.configure(with: providers)
      }
      if let observable = value as? FAPIObservable {
        observable.addObserver(self)
      }
    }
  }
}

extension FAPCollection: FAPIParentCollection {
  var subCollection: FAPICollection? {
    wrappedValue
  }
}

extension FAPCollection: FAPIProviderObserver {
  func didChangeValue(key: String?) {
    subscribers.forEach { $0.value(wrappedValue) }
    observer?.didChangeValue(key: key)
  }
}

extension FAPCollection: FAPIObservable {
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
