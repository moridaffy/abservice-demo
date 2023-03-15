import Foundation

struct ABMainTextConfig: Codable {
  let title: String
  let subtitle: String
  let textColor: String

  enum CodingKeys: String, CodingKey {
    case title
    case subtitle
    case textColor = "text_color"
  }
}
