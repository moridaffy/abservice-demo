import Foundation

// MARK: - Int

extension Int: FAPIValue {
  init?(encoded value: FAPValueType) {
    guard case .integer(let value) = value else {
      return nil
    }

    self = value
  }

  func encoded() -> FAPValueType {
    .integer(self)
  }
}

// MARK: - String

extension String: FAPIValue {
  init?(encoded value: FAPValueType) {
    guard case .string(let value) = value else {
      return nil
    }

    self = value
  }

  func encoded() -> FAPValueType {
    .string(self)
  }
}

// MARK: - Bool

extension Bool: FAPIValue {
  init?(encoded value: FAPValueType) {
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

  func encoded() -> FAPValueType {
    .boolean(self)
  }
}

// MARK: - Codable

extension Decodable where Self: FAPIValue, Self: Encodable {
  init?(encoded value: FAPValueType) {
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

extension Encodable where Self: FAPIValue, Self: Decodable {
  func encoded() -> FAPValueType {
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .sortedKeys
      return .data(try encoder.encode(self))
    } catch {
      return .data(Data())
    }
  }
}
