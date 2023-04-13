import Foundation

extension Configuration {
  struct Flag: Codable {
    let key: String
    let value: Any?

    let conditionTrueValue: Any?
    let conditionFalseValue: Any?
    let conditions: [Configuration.Condition]?

    enum CodingKeys: String, CodingKey {
      case key
      case value

      case conditionTrueValue = "condition_true_value"
      case conditionFalseValue = "condition_false_value"
      case conditions
    }
  }
}

// MARK: - Decodable

extension Configuration.Flag {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.key = try container.decode(String.self, forKey: .key)
    self.value = try Configuration.decode(from: container, forKey: .value)

    self.conditionTrueValue = try Configuration.decode(from: container, forKey: .conditionTrueValue)
    self.conditionFalseValue = try Configuration.decode(from: container, forKey: .conditionFalseValue)
    self.conditions = try container.decodeIfPresent([Configuration.Condition].self, forKey: .conditions)
  }
}

// MARK: - Encodable

extension Configuration.Flag {
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.key, forKey: .key)
    try Configuration.encode(to: &container, forKey: .value, value: self.value)
    
    try Configuration.encode(to: &container, forKey: .conditionTrueValue, value: self.conditionTrueValue)
    try Configuration.encode(to: &container, forKey: .conditionFalseValue, value: self.conditionFalseValue)
    try container.encodeIfPresent(self.conditions, forKey: .conditions)
  }
}
