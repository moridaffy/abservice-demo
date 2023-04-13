import Foundation

struct MainTextConfig: Codable {
  let title: String
  let subtitle: String
  let textColor: String

  enum CodingKeys: String, CodingKey {
    case title
    case subtitle
    case textColor = "text_color"
  }
}

extension MainTextConfig: WWFIValue {
  init?(encoded value: WWFValueType) {
    switch value {
    case let .model(value):
      guard let value = value as? MainTextConfig else { return nil }
      self = value

    case let .data(value):
      do {
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: value)
      } catch {
        return nil
      }

    default:
      return nil
    }
  }

  func encoded() -> WWFValueType {
    .model(self)
  }
}

extension MainTextConfig {
  static var empty: Self {
    .init(title: "", subtitle: "", textColor: "")
  }
}
