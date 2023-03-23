import Foundation

class DefaultConfigProvider {
  private let decoder: JSONDecoder

  private(set) var config: ABConfig?

  let priority: ABConfigProviderPriority = .low

  init(decoder: JSONDecoder) {
    self.decoder = decoder
  }
}

extension DefaultConfigProvider: IABConfigProvider {
  func fetchConfig(completion: @escaping (Error?) -> Void) {
    guard let localUrl = Bundle.main.url(forResource: "config", withExtension: "json") else {
      assertionFailure("Missing local default AB config")
      return
    }

    do {
      let localData = try Data(contentsOf: localUrl)
      let config = try decoder.decode(ABConfig.self, from: localData)
      self.config = config
      completion(nil)
    } catch let error {
      completion(error)
    }
  }

  func getValue(for key: ABValueKey) -> Any? {
    let flag = config?.collections
      .flatMap { $0.flags }
      .first(where: { $0.key == key.rawValue })
    guard let flag = flag else { return nil }

    if let conditions = flag.conditions {
      return ABConditionResolver.resolve(conditions) ? flag.conditionTrueValue : flag.conditionFalseValue
    } else {
      return flag.value
    }
  }
}
