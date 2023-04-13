import Foundation

extension DebugEditView {
  class Model {
    let key: String
    let value: WWFValueType
    
    weak var provider: WWFISettableProvider?

    init(key: String, value: WWFValueType,  provider: WWFISettableProvider?) {
      self.key = key
      self.value = value

      assert(provider != nil)
      self.provider = provider
    }

    func read() -> String {
      guard let model = value.value as? Codable,
            let data = try? JSONEncoder().encode(model),
            let object = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
            let prettyString = String(data: prettyData, encoding: .utf8) else {
        return "failed to parse"
      }

      return prettyString
    }

    func save(_ value: String?, completion: (Result<Bool, Error>) -> Void) {
      guard let string = value?.nilIfEmpty,
            let data = string.data(using: .utf8) else {
        completion(.failure(NSError(domain: "ab", code: 0)))
        return
      }

      // check if json is valid
      guard (try? JSONSerialization.jsonObject(with: data)) != nil else {
        completion(.failure(NSError(domain: "ab", code: 1)))
        return
      }

      provider?.setValue(data, forKey: key)
      completion(.success(true))
    }
  }
}
