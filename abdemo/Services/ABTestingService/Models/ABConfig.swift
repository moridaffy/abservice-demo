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

    let conditionTrueValue: Any?
    let conditionFalseValue: Any?
    let conditions: [Condition]?

    var valueKey: ABValueKey? {
      ABValueKey(rawValue: key)
    }

    enum CodingKeys: String, CodingKey {
      case key
      case description
      case value

      case conditionTrueValue = "condition_true_value"
      case conditionFalseValue = "condition_false_value"
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
        self.conditionTrueValue = nil
        self.conditionFalseValue = nil
        return
      }

      switch valueType {
      case .string:
        self.value = try values.decodeIfPresent(String.self, forKey: .value)
        self.conditionTrueValue = try values.decodeIfPresent(String.self, forKey: .conditionTrueValue)
        self.conditionFalseValue = try values.decodeIfPresent(String.self, forKey: .conditionFalseValue)

      case .int:
        self.value = try values.decodeIfPresent(Int.self, forKey: .value)
        self.conditionTrueValue = try values.decodeIfPresent(Int.self, forKey: .conditionTrueValue)
        self.conditionFalseValue = try values.decodeIfPresent(Int.self, forKey: .conditionFalseValue)

      case .bool:
        self.value = try values.decodeIfPresent(Bool.self, forKey: .value)
        self.conditionTrueValue = try values.decodeIfPresent(Bool.self, forKey: .conditionTrueValue)
        self.conditionFalseValue = try values.decodeIfPresent(Bool.self, forKey: .conditionFalseValue)

      case let .model(type):
        self.value = Self.decodeModel(of: type, from: values, at: .value)
        self.conditionTrueValue = Self.decodeModel(of: type, from: values, at: .conditionTrueValue)
        self.conditionFalseValue = Self.decodeModel(of: type, from: values, at: .conditionFalseValue)
      }
    }

    init(key: String, description: String?, value: Any?) {
      self.key = key
      self.description = description
      self.value = value

      self.conditionTrueValue = nil
      self.conditionFalseValue = nil
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
        if let value = value as? Encodable,
           let data = try? JSONEncoder().encode(value),
           let model = try? JSONDecoder().decode(type, from: data) {
          try container.encode(model, forKey: .value)
        } else if let value = value as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: value) {
          try container.encode(data, forKey: .value)
        } else {
          try container.encodeNil(forKey: .value)
        }
      }
    }

    var copy: Flag {
      .init(key: key, description: description, value: value)
    }
  }
}

private extension ABConfig.Flag {
  static func decodeModel<T: Codable>(of type: T.Type, from container: KeyedDecodingContainer<ABConfig.Flag.CodingKeys>, at key: ABConfig.Flag.CodingKeys) -> T? {
    if let model = try? container.decodeIfPresent(type, forKey: key) {
      return model
    } else if let data = try? container.decodeIfPresent(Data.self, forKey: key),
              let model = try? JSONDecoder().decode(type, from: data) {
      return model
    } else {
      return nil
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
