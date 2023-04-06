import Foundation

struct FAPKeyPath: Hashable {
  static let defaultSeparator = "/"

  let collection: String
  let key: String
  let separator: String

  var path: String {
    [collection, key].joined(separator: separator)
  }

  init(collection: String, key: String, separator: String = FAPKeyPath.defaultSeparator) {
    self.collection = collection
    self.key = key
    self.separator = separator
  }

  init?(path: String, separator: String = FAPKeyPath.defaultSeparator) {
    let components = path.split(separator: separator)
    guard components.count == 2,
          let collection = components.first,
          let key = components.last else { return nil }
    self.collection = String(collection)
    self.key = String(key)
    self.separator = separator
  }
}
