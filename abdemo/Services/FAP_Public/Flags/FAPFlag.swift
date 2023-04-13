import Foundation

// MARK: - Protocols

protocol FAPIFlag: FAPIConfigurableWithProviders {
  var key: String { get }
  var value: FAPValueType? { get }
}

// MARK: - FAPCollection

@propertyWrapper
class FAPFlag<Value: FAPIValue>: Identifiable, FAPIFlag {
  private typealias ValueSource = (value: Value?, source: FAPIProvider?)

  let id: UUID = UUID()
  let key: String

  var wrappedValue: Value {
    get {
      flagValue().value ?? defaultValue
    }
    set {
      for provider in providers {
        guard let provider = provider as? FAPISettableProvider else { continue }
        provider.setValue(value, forKey: key)
      }
      notifyObserversIfNeeded()
    }
  }
  var value: FAPValueType? {
    wrappedValue.encoded()
  }

  private var previousValue: Value?
  private var defaultValue: Value

  private var providers: [FAPIProvider] = []
  private var subscribers: [AnyWrapper: ((Value) -> Void)] = [:]
  private weak var observer: FAPIProviderObserver?
  
  init(key: String,
       default defaultValue: Value) {
    self.key = key
    self.defaultValue = defaultValue
  }

  func subscribe(_ subscriber: AnyHashable, block: @escaping (Value) -> Void) {
    let subscriber = AnyWrapper(subscriber)
    subscribers[subscriber] = block
    block(wrappedValue)
  }
}

private extension FAPFlag {
  private func flagValue() -> ValueSource {
    for provider in providers {
      if let value: Value = provider.getValue(forKey: key) {
        print("🔥 \(provider.name): \(key) - \(value)")
        return (value: value, source: provider)
      }
    }

    return (value: nil, source: nil)
  }

  func notifyObserversIfNeeded() {
    let currentValue = wrappedValue
    guard currentValue != previousValue else { return }
    previousValue = currentValue

    subscribers.forEach { $0.value(currentValue) }
    observer?.didChangeValue(key: key)
  }
}

extension FAPFlag: FAPIObservable {
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

extension FAPFlag: FAPIConfigurableWithProviders {
  func configure(with providers: [FAPIProvider]) {
    providers.forEach { $0.addObserver(self, forKey: key) }
    self.providers = providers
    previousValue = wrappedValue
  }
}

extension FAPFlag: FAPIProviderObserver {
  func didChangeValue(key: String?) {
    notifyObserversIfNeeded()
  }
}
