import Foundation

// MARK: - Protocols

protocol WWFIProvider: AnyObject, WWFIObservable {
  var name: String { get }

  func getValue<Value>(forKey key: String) -> Value?
}

protocol WWFISettableProvider: AnyObject {
  @discardableResult
  func setValue<Value>(_ value: Value?, forKey key: String) -> Bool
}

protocol WWFIResettableProvider: AnyObject {
  func reset()
  func resetValue(forKey key: String)
}

protocol WWFIProviderObserver: Observer {
  func didChangeValue(key: String?)
}

protocol WWFIConfigurableWithProviders {
  func configure(with providers: [WWFIProvider])
}

protocol WWFIObservable {
  func addObserver(_ observer: WWFIProviderObserver, forKey key: String?)
  func removeObserver(_ observer: WWFIProviderObserver)
}

extension WWFIObservable {
  func addObserver(_ observer: WWFIProviderObserver) {
    addObserver(observer, forKey: nil)
  }
}

// MARK: - Implementation

class WWFProvider: WWFIProvider {
  var name: String {
    assertionFailure("Must be implemented in subclass")
    return "Default"
  }

  var values: [String: Any?] = [:]
  private var observers: [String: WeakObserver] = [:]

  func getValue<Value>(forKey key: String) -> Value? {
    guard let rawValue = values[key] else {
      return nil
    }

    if let value = rawValue as? Value {
      return value
    }

    if let modelType = Value.self as? Decodable.Type,
       let data = rawValue as? Data,
       let model = try? JSONDecoder().decode(modelType, from: data) {
      return model as? Value
    }

    return nil
  }
}

internal extension WWFProvider {
  func notifyObservers(keys: [String]) {
    for key in keys {
      guard let observer = observers[key]?.observer as? WWFIProviderObserver else { continue }
      observer.didChangeValue(key: key)
    }
  }
}

extension WWFProvider: WWFIObservable {
  func addObserver(_ observer: WWFIProviderObserver, forKey key: String?) {
    guard let key = key else {
      assertionFailure()
      return
    }

    if observers[key] != nil {
      assertionFailure()
    }

    observers[key] = .init(observer: observer)
    observer.didChangeValue(key: key)
  }

  func removeObserver(_ observer: WWFIProviderObserver) {
    guard let key = observers.first(where: { $0.value.observer === observer })?.key else {
      assertionFailure()
      return
    }

    observers.removeValue(forKey: key)
  }
}
