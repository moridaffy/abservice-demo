import Foundation

struct Configuration: Codable {
  let version: Int
  let updateDate: TimeInterval
  let collections: [Configuration.Collection]

  enum CodingKeys: String, CodingKey {
    case version
    case updateDate = "update_date"
    case collections
  }
}

extension Configuration {
  func parse(resolver: FAPConditionResolver = .shared) -> [FAPKeyPath: Any?] {
    var values: [FAPKeyPath: Any?] = [:]

    for collection in collections {
      for flag in collection.flags {
        let keyPath = FAPKeyPath(collection: collection.key, key: flag.key)
        let value: Any?

        if let conditions = flag.conditions,
           !conditions.isEmpty {
          value = resolver.resolve(conditions) ? flag.conditionTrueValue : flag.conditionFalseValue
        } else {
          value = flag.value
        }

        values[keyPath] = value
      }
    }

    return values
  }
}

// MARK: - Decoding & encoding

extension Configuration {
  static let possibleCodableTypes: [Codable.Type] = [
    MainTextConfig.self
  ]

  static func decode<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: K) throws -> Any? {
    if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
      return value
    } else if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
      return value
    } else if let value = try? container.decodeIfPresent(Float.self, forKey: key) {
      return value
    } else if let value = try? container.decodeIfPresent(String.self, forKey: key) {
      return value
    } else if let value = try? container.decodeIfPresent(Bool.self, forKey: key) {
      return value
    } else if let value = try? container.decodeIfPresent(Data.self, forKey: key) {
      return value
    } else {
      for type in possibleCodableTypes {
        if let value = try? container.decodeIfPresent(type, forKey: key) {
          return value
        }
      }

      return nil
    }
  }

  static func encode<K: CodingKey>(to container: inout KeyedEncodingContainer<K>, forKey key: K, value: Any?) throws {
    guard let value = value else {
      try container.encodeNil(forKey: key)
      return
    }

    if let value = value as? Int {
      try container.encode(value, forKey: key)
    } else if let value = value as? Double {
      try container.encode(value, forKey: key)
    } else if let value = value as? Float {
      try container.encode(value, forKey: key)
    } else if let value = value as? String {
      try container.encode(value, forKey: key)
    } else if let value = value as? Bool {
      try container.encode(value, forKey: key)
    } else if let value = value as? Data {
      try container.encode(value, forKey: key)
    } else {
      try container.encodeNil(forKey: key)
    }
  }
}
