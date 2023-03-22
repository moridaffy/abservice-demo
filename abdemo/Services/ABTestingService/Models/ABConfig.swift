import Foundation

// MARK: - ABConfig

class ABConfig: Codable {
  let version: Int
  let updateDate: TimeInterval
  var collections: [Collection]

  enum CodingKeys: String, CodingKey {
    case version
    case updateDate = "update_date"
    case collections
  }

  init(version: Int = .zero, updateDate: TimeInterval = Date().timeIntervalSince1970, collections: [Collection]) {
    self.version = version
    self.updateDate = updateDate
    self.collections = collections
  }
}

extension ABConfig {
  static var empty: ABConfig {
    .init(collections: [])
  }
}

// MARK: - Collection

extension ABConfig {
  class Collection: Codable {
    let name: String
    var flags: [Flag]

    init(name: String, flags: [Flag] = []) {
      self.name = name
      self.flags = flags
    }
  }
}

// MARK: - Flag

extension ABConfig {
  class Flag: Codable {
    let key: String
    let description: String?
    var value: Any?

    let preConditionValue: Any?
    let afterConditionValue: Any?
    let conditions: [Condition]?

    var valueKey: ABValueKey? {
      ABValueKey(rawValue: key)
    }

    enum CodingKeys: String, CodingKey {
      case key
      case description
      case value

      case preConditionValue = "pre_condition_value"
      case afterConditionValue = "after_condition_value"
      case conditions
    }

    required init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      let key = try values.decode(String.self, forKey: .key)
      self.key = key
      self.description = try values.decodeIfPresent(String.self, forKey: .description)
      self.conditions = try values.decodeIfPresent([Condition].self, forKey: .conditions)

      guard let valueType = ABValueKey(rawValue: key)?.valueType else {
        self.value = nil
        self.preConditionValue = nil
        self.afterConditionValue = nil
        return
      }

      switch valueType {
      case .string:
        self.value = try values.decodeIfPresent(String.self, forKey: .value)
        self.preConditionValue = try values.decodeIfPresent(String.self, forKey: .preConditionValue)
        self.afterConditionValue = try values.decodeIfPresent(String.self, forKey: .afterConditionValue)

      case .int:
        self.value = try values.decodeIfPresent(Int.self, forKey: .value)
        self.preConditionValue = try values.decodeIfPresent(Int.self, forKey: .preConditionValue)
        self.afterConditionValue = try values.decodeIfPresent(Int.self, forKey: .afterConditionValue)

      case .bool:
        self.value = try values.decodeIfPresent(Bool.self, forKey: .value)
        self.preConditionValue = try values.decodeIfPresent(Bool.self, forKey: .preConditionValue)
        self.afterConditionValue = try values.decodeIfPresent(Bool.self, forKey: .afterConditionValue)

      case let .model(type):
        self.value = try values.decodeIfPresent(type, forKey: .value)
        self.preConditionValue = try values.decodeIfPresent(type, forKey: .preConditionValue)
        self.afterConditionValue = try values.decodeIfPresent(type, forKey: .afterConditionValue)
      }
    }

    init(key: String, description: String?, value: Any?) {
      self.key = key
      self.description = description
      self.value = value

      self.preConditionValue = nil
      self.afterConditionValue = nil
      self.conditions = nil
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(key, forKey: .key)
      try container.encodeIfPresent(description, forKey: .description)

      guard let valueType = ABValueKey(rawValue: key)?.valueType else {
        try container.encodeNil(forKey: .value)
        return
      }

      switch valueType {
      case .string:
        try container.encode(value as? String, forKey: .value)

      case .int:
        try container.encode(value as? Int, forKey: .value)

      case .bool:
        try container.encode(value as? Bool, forKey: .value)

      case let .model(type):
        guard let value = value as? Encodable,
              let data = try? JSONEncoder().encode(value),
              let model = try? JSONDecoder().decode(type, from: data) else {
          try container.encodeNil(forKey: .value)
          return
        }
        try container.encode(model, forKey: .value)
      }
    }

    var copy: Flag {
      .init(key: key, description: description, value: value)
    }
  }
}

// MARK: - Condition

extension ABConfig {
  struct Condition: Codable {
    let key: String
    let value: Any?

    enum CodingKeys: String, CodingKey {
      case key
      case value
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      self.key = try values.decode(String.self, forKey: .key)

      guard let valueType = ABConditionKey(rawValue: key)?.valueType else {
        self.value = nil
        return
      }

      switch valueType {
      case .string:
        self.value = try values.decodeIfPresent(String.self, forKey: .value)

      case .int:
        self.value = try values.decodeIfPresent(Int.self, forKey: .value)

      case .bool:
        self.value = try values.decodeIfPresent(Bool.self, forKey: .value)

      case let .model(type):
        self.value = try values.decodeIfPresent(type, forKey: .value)
      }

    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(key, forKey: .key)

      guard let valueType = ABConditionKey(rawValue: key)?.valueType else {
        try container.encodeNil(forKey: .value)
        return
      }

      switch valueType {
      case .string:
        try container.encode(value as? String, forKey: .value)

      case .int:
        try container.encode(value as? Int, forKey: .value)

      case .bool:
        try container.encode(value as? Bool, forKey: .value)

      case let .model(type):
        guard let value = value as? Encodable,
              let data = try? JSONEncoder().encode(value),
              let model = try? JSONDecoder().decode(type, from: data) else {
          try container.encodeNil(forKey: .value)
          return
        }
        try container.encode(model, forKey: .value)
      }
    }
  }
}
