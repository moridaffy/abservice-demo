import Foundation

extension Configuration {
  struct Collection: Codable {
    let key: String
    let flags: [Configuration.Flag]

    enum CodingKeys: String, CodingKey {
      case key
      case flags
    }
  }
}
