import Foundation

protocol FAPIProvider: AnyObject {
  var name: String { get }
  var description: String { get }
  var isWritable: Bool { get }

  var loader: FAPILoader? { get set }

  @discardableResult
  func setValue<Value>(_ value: Value?, forKey key: FAPKeyPath) -> Bool
  func getValue<Value>(forKey key: FAPKeyPath) -> Value?

  func resetValue(forKey key: FAPKeyPath)
  func reset()
}

class FAPProvider: FAPIProvider {
  var name: String {
    assertionFailure("Must be implemented in subclass")
    return "Default"
  }
  var description: String {
    assertionFailure("Must be implemented in subclass")
    return "Unimplemented provider"
  }
  var isWritable: Bool {
    assertionFailure("Must be implemented in subclass")
    return false
  }

  var values: [FAPKeyPath: Any?] = [:]

  weak var loader: FAPILoader?

  @discardableResult
  func setValue<Value>(_ value: Value?, forKey key: FAPKeyPath) -> Bool {
    guard isWritable else { return false }
    self.values[key] = value

    // TODO: придумать, как определять, изменилось ли значение
    let hasChanged = true
    if hasChanged {
      notifyObservers(keys: [key])
    }

    return true
  }

  func getValue<Value>(forKey key: FAPKeyPath) -> Value? {
    let rawValue = values[key]
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

  func resetValue(forKey key: FAPKeyPath) {
    let valueExisted = values[key] != nil
    values.removeValue(forKey: key)

    if valueExisted {
      notifyObservers(keys: [key])
    }
  }

  func reset() {
    let keys = values.compactMap { $0.key }
    values.removeAll()
    notifyObservers(keys: keys)
  }
}

private extension FAPProvider {
  func notifyObservers(keys: [FAPKeyPath]) {
    loader?.didChangeValue(keys: keys)
  }
}
