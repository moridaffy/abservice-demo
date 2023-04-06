import Foundation

extension DebugEditView {
  class Model {
    let keyPath: FAPKeyPath
    let value: FAPValueType
    
    weak var provider: FAPIProvider?

    init(keyPath: FAPKeyPath, value: FAPValueType,  provider: FAPIProvider?) {
      self.keyPath = keyPath
      self.value = value

      assert(provider != nil)
      self.provider = provider
    }

    func read() -> String {
      guard let model = value.value as? Codable else {
        return "no model"
      }

      guard let data = try? JSONEncoder().encode(model) else {
        return "no data"
      }

      guard let object = try? JSONSerialization.jsonObject(with: data) else {
        return "no object"
      }

      guard let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]) else {
        return "no pretty data"
      }

      guard let string = String(data: prettyData, encoding: .utf8) else {
        return "no pretty string"
      }

      return string
    }

    func save(_ value: String?, completion: (Result<Bool, Error>) -> Void) {
      // TODO
      completion(.failure(NSError(domain: "ab", code: 0)))
    }
  }
}
