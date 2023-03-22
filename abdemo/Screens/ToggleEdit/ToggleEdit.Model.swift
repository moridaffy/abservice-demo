import Foundation

extension FlagEdit {
  class Model {
    private let abTestingService: IABTestingService

    private lazy var decoder = JSONDecoder()

    let flag: ABConfig.Flag

    init(abTestingService: IABTestingService, flag: ABConfig.Flag) {
      self.abTestingService = abTestingService

      self.flag = flag
    }

    func getReadableValue() -> String? {
      abTestingService.getReadableValue(for: flag)
    }

    func saveChanges(_ value: String) -> Bool {
      guard case let .model(type) = flag.valueKey?.valueType else {
        assertionFailure()
        return false
      }

      guard let stringValue = value.nilIfEmpty,
            let dataValue = stringValue.data(using: .utf8),
            let model = try? decoder.decode(type, from: dataValue) else {
        return false
      }

      let newFlag = flag.copy
      newFlag.value = model
      abTestingService.setOverriddenFlag(newFlag)

      return true
    }
  }
}
