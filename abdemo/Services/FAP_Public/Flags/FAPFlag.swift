import Foundation

protocol FAPIFlag {
  var key: String { get }
  var value: FAPValueType? { get }
}

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

  private let loader = FAPLoaderWrapper()
  
  init(key: String,
       default defaultValue: Value) {
    self.key = key
    self.defaultValue = defaultValue
  }

  func setDefault(_ value: Value) {
    self.defaultValue = value
    notifyObserversIfNeeded()
  }

  func subscribe(block: @escaping (Value) -> Void) {
    // TODO:
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

    loader.loader?.didChangeValue(keys: [key])
  }
}
