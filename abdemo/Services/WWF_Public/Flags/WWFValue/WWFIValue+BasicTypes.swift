import Foundation

// MARK: - Int

extension Int: WWFIValue {
  init?(encoded value: WWFValueType) {
    guard case .integer(let value) = value else {
      return nil
    }

    self = value
  }

  func encoded() -> WWFValueType {
    .integer(self)
  }
}

// MARK: - String

extension String: WWFIValue {
  init?(encoded value: WWFValueType) {
    guard case .string(let value) = value else {
      return nil
    }

    self = value
  }

  func encoded() -> WWFValueType {
    .string(self)
  }
}

extension Array: WWFIValue where Element == String {
  init?(encoded value: WWFValueType) {
    guard case .array(let array) = value else {
      return nil
    }

    self = array.compactMap { $0.value as? String }
  }

  func encoded() -> WWFValueType {
    .array(self.compactMap { .string($0) })
  }
}

// MARK: - Bool

extension Bool: WWFIValue {
  init?(encoded value: WWFValueType) {
    switch value {
    case .boolean(let v):
      self = v
    case .integer(let v):
      self = (v != 0)
    case .string(let v):
      self = (v as NSString).boolValue
    default:
      return nil
    }
  }

  func encoded() -> WWFValueType {
    .boolean(self)
  }
}

// MARK: - Codable

extension Decodable where Self: WWFIValue, Self: Encodable {
  init?(encoded value: WWFValueType) {
    guard case .data(let data) = value else {
      return nil
    }

    do {
      let decoder = JSONDecoder()
      self = try decoder.decode(Self.self, from: data)
    } catch {
      return nil
    }
  }
}

extension Encodable where Self: WWFIValue, Self: Decodable {
  func encoded() -> WWFValueType {
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .sortedKeys
      return .data(try encoder.encode(self))
    } catch {
      return .data(Data())
    }
  }
}
