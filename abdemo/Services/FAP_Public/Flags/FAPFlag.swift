import Foundation

protocol FAPIFlag {
  var keyPath: FAPKeyPath { get }
  var value: FAPValueType? { get }
}

@propertyWrapper
class FAPFlag<Value: FAPIValue>: Identifiable, FAPIFlag {
  private typealias ValueSource = (value: Value?, source: FAPIProvider?)

  let id: UUID = UUID()
  let keyPath: FAPKeyPath

  var wrappedValue: Value? {
    flagValue().value ?? defaultValue
  }
  var value: FAPValueType? {
    wrappedValue?.encoded()
  }

  private var previousValue: Value?
  private var defaultValue: Value?

  private let loader = FAPLoaderWrapper()
  
  init(keyPath: FAPKeyPath,
       default defaultValue: Value? = nil) {
    self.keyPath = keyPath
    self.defaultValue = defaultValue
  }

  func setDefault(_ value: Value?) {
    self.defaultValue = value
    notifyObserversIfNeeded()
  }

  func set(_ value: Value?) {
    providers.forEach { $0.setValue(value, forKey: keyPath) }
    notifyObserversIfNeeded()
  }

  func reset() {
    providers.forEach { $0.resetValue(forKey: keyPath) }
    notifyObserversIfNeeded()
  }
}

extension FAPFlag: FAPIConfigurableWithLoader {
  func configure(with loader: FAPILoader) {
    self.loader.loader = loader

    previousValue = wrappedValue
  }
}

private extension FAPFlag {
  var providers: [FAPIProvider] {
    loader.loader?.providers ?? []
  }

  private func flagValue() -> ValueSource {
    if loader.loader == nil {
      return (value: defaultValue, source: nil)
    }

    for provider in providers {
      if let value: Value = provider.getValue(forKey: keyPath) {
        print("🔥 \(provider.name): \(keyPath.path) - \(value)")
        return (value: value, source: provider)
      }
    }

    return (value: nil, source: nil)
  }

  func notifyObserversIfNeeded() {
    let currentValue = wrappedValue
    guard currentValue != previousValue else { return }
    previousValue = currentValue

    loader.loader?.didChangeValue(keys: [keyPath])
  }
}
