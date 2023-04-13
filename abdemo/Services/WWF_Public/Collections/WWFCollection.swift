import Foundation

// MARK: - Protocols

protocol WWFICollection {
  var providers: [WWFIProvider] { get }

  init()
}

protocol WWFIParentCollection {
  var subCollection: WWFICollection? { get }
}

// MARK: - WWFCollection

@propertyWrapper
class WWFCollection<Collection: WWFICollection>: Identifiable {
  let id: UUID = UUID()

  var wrappedValue: Collection

  private var key: String?

  private(set) var providers: [WWFIProvider] = []
  private var subscribers: [AnyWrapper: ((Collection) -> Void)] = [:]
  private weak var observer: WWFIProviderObserver?

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

extension WWFCollection: WWFIConfigurableWithProviders {
  func configure(with providers: [WWFIProvider]) {
    self.providers = providers

    Mirror(reflecting: wrappedValue).children.lazy.forEach { child in
      let value = child.value
      if let configurable = value as? WWFIConfigurableWithProviders {
        configurable.configure(with: providers)
      }
      if let observable = value as? WWFIObservable {
        observable.addObserver(self)
      }
    }
  }
}

extension WWFCollection: WWFIParentCollection {
  var subCollection: WWFICollection? {
    wrappedValue
  }
}

extension WWFCollection: WWFIProviderObserver {
  func didChangeValue(key: String?) {
    subscribers.forEach { $0.value(wrappedValue) }
    observer?.didChangeValue(key: key)
  }
}

extension WWFCollection: WWFIObservable {
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
