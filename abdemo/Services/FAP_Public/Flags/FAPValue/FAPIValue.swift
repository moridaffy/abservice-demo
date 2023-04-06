import Foundation

protocol FAPIValue: Equatable {
  init?(encoded value: FAPValueType)
  func encoded() -> FAPValueType
}

enum FAPValueType {
  case integer(Int)
  case double(Double)
  case float(Float)
  case string(String)
  case boolean(Bool)
  case model(Codable)
  case data(Data)
  case array([FAPValueType])
  case none

  init?(value: Any) {
    switch value {
    case let value as Int:
      self = .integer(value)

    case let value as Double:
      self = .double(value)

    case let value as Float:
      self = .float(value)

    case let value as String:
      self = .string(value)

    case let value as Bool:
      self = .boolean(value)

    case let value as Codable:
      self = .model(value)

    case let value as Data:
      self = .data(value)

    case let value as [Any]:
      self = .array(value.compactMap { FAPValueType(value: $0) })

    default:
      self = .none
    }
  }

  var value: Any? {
    switch self {
    case let .integer(value):
      return value

    case let .double(value):
      return value

    case let .float(value):
      return value

    case let .string(value):
      return value

    case let .boolean(value):
      return value

    case let .model(value):
      return value

    case let .data(value):
      return value

    case let .array(value):
      return value

    case .none:
      return nil
    }
  }

  var description: String {
    switch self {
    case let .integer(value):
      return "\(value)"

    case let .double(value):
      return "\(value)"

    case let .float(value):
      return "\(value)"

    case let .string(value):
      return value

    case let .boolean(value):
      return value ? "true" : "false"

    case let .model(value):
      return String(describing: type(of: value))

    case let .data(value):
      return String(describing: value)

    case let .array(value):
      return [
        "[",
        value.compactMap { $0.description.nilIfEmpty }.joined(separator: ", "),
        "]"
      ].joined()

    case .none:
      return "nil"
    }
  }
}
