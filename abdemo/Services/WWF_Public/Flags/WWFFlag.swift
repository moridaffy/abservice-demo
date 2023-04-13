import Foundation

// MARK: - Protocols

protocol WWFIFlag: WWFIConfigurableWithProviders {
  var key: String { get }
  var value: WWFValueType? { get }
}

// MARK: - WWFCollection

@propertyWrapper
class WWFFlag<Value: WWFIValue>: Identifiable, WWFIFlag {
  private typealias ValueSource = (value: Value?, source: WWFIProvider?)

  let id: UUID = UUID()
  let key: String

  var wrappedValue: Value {
    get {
      flagValue().value ?? defaultValue
    }
    set {
      for provider in providers {
        guard let provider = provider as? WWFISettableProvider else { continue }
        provider.setValue(value, forKey: key)
      }
      notifyObserversIfNeeded()
    }
  }
  var value: WWFValueType? {
    wrappedValue.encoded()
  }

  private var previousValue: Value?
  private var defaultValue: Value

  private var providers: [WWFIProvider] = []
  private var subscribers: [AnyWrapper: ((Value) -> Void)] = [:]
  private weak var observer: WWFIProviderObserver?
  
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

private extension WWFFlag {
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

extension WWFFlag: WWFIObservable {
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

extension WWFFlag: WWFIConfigurableWithProviders {
  func configure(with providers: [WWFIProvider]) {
    providers.forEach { $0.addObserver(self, forKey: key) }
    self.providers = providers
    previousValue = wrappedValue
  }
}

extension WWFFlag: WWFIProviderObserver {
  func didChangeValue(key: String?) {
    notifyObserversIfNeeded()
  }
}
