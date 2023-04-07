import Foundation

protocol FAPIProvider: AnyObject {
  var name: String { get }

  var loader: FAPILoader? { get set }

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

extension FAPIProvider {
  func reset() { }
}

class FAPProvider: FAPIProvider {
  var name: String {
    assertionFailure("Must be implemented in subclass")
    return "Default"
  }

  var values: [String: Any?] = [:]

  weak var loader: FAPILoader?

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
    loader?.didChangeValue(keys: keys)
  }
}
