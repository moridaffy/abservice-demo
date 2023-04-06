import Foundation

extension Configuration {
  struct Condition: Codable {
    let key: String
    let value: Any?

    enum CodingKeys: String, CodingKey {
      case key
      case value
    }
  }
}

// MARK: - Decodable

extension Configuration.Condition {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.key = try container.decode(String.self, forKey: .key)
    self.value = try Configuration.decode(from: container, forKey: .value)
  }
}

// MARK: - Encodable

extension Configuration.Condition {
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.key, forKey: .key)
    try Configuration.encode(to: &container, forKey: .value, value: self.value)
  }
}
