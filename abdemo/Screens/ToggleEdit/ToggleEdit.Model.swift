import Foundation

extension FlagEdit {
  class Model {
    private let abTestingService: IABTestingService

    private lazy var decoder = JSONDecoder()

    let flag: ABConfig.Flag

    var readableValue: String? {
      guard let key = flag.valueKey else {
        assertionFailure()
        return "error"
      }

      guard let value = abTestingService.getValue(forKey: key) else {
        return "nil"
      }

      if let encodable = value as? Encodable {
        return readableValue(for: encodable)
      } else if let dictionary = value as? [String: Any] {
        return readableValue(for: dictionary)
      } else {
        assertionFailure()
        return "error"
      }
    }

    init(abTestingService: IABTestingService, flag: ABConfig.Flag) {
      self.abTestingService = abTestingService

      self.flag = flag
    }

    func saveChanges(_ value: String) -> Bool {
      guard let key = flag.valueKey else { return false }

      guard let stringValue = value.nilIfEmpty,
            let dataValue = stringValue.data(using: .utf8),
            let model = try? JSONSerialization.jsonObject(with: dataValue) else {
        return false
      }

      abTestingService.setOverriddenFlag(forKey: key, value: model)
      return true
    }
  }
}

private extension FlagEdit.Model {
  func readableValue(for encodable: Encodable) -> String? {
    guard let data = try? JSONEncoder().encode(encodable) else {
      return nil
    }

    return data.prettyString
  }

  func readableValue(for dictionary: [String: Any]) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted, .sortedKeys]) else {
      return nil
    }

    return data.prettyString
  }
}
