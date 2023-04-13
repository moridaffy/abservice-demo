import Foundation

// MARK: - Protocols

protocol FAPIProvider: AnyObject, FAPIObservable {
  var name: String { get }

  func getValue<Value>(forKey key: String) -> Value?
}

protocol FAPISettableProvider: AnyObject {
  @discardableResult
  func setValue<Value>(_ value: Value?, forKey key: String) -> Bool
}

protocol FAPIResettableProvider: AnyObject {
  func reset()
  func resetValue(forKey key: String)
}

protocol FAPIProviderObserver: Observer {
  func didChangeValue(key: String?)
}

protocol FAPIConfigurableWithProviders {
  func configure(with providers: [FAPIProvider])
}

protocol FAPIObservable {
  func addObserver(_ observer: FAPIProviderObserver, forKey key: String?)
  func removeObserver(_ observer: FAPIProviderObserver)
}

extension FAPIObservable {
  func addObserver(_ observer: FAPIProviderObserver) {
    addObserver(observer, forKey: nil)
  }
}

// MARK: - Implementation

class FAPProvider: FAPIProvider {
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

internal extension FAPProvider {
  func notifyObservers(keys: [String]) {
    for key in keys {
      guard let observer = observers[key]?.observer as? FAPIProviderObserver else { continue }
      observer.didChangeValue(key: key)
    }
  }
}

extension FAPProvider: FAPIObservable {
  func addObserver(_ observer: FAPIProviderObserver, forKey key: String?) {
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

  func removeObserver(_ observer: FAPIProviderObserver) {
    guard let key = observers.first(where: { $0.value.observer === observer })?.key else {
      assertionFailure()
      return
    }

    observers.removeValue(forKey: key)
  }
}
