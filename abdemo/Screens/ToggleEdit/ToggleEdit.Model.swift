import Foundation

extension ToggleEdit {
  class Model {
    private let abTestingService: IABTestingService

    private lazy var decoder = JSONDecoder()

    let toggle: ABConfig.Toggle

    init(abTestingService: IABTestingService, toggle: ABConfig.Toggle) {
      self.abTestingService = abTestingService

      self.toggle = toggle
    }

    func getReadableValue() -> String? {
      abTestingService.getReadableValue(for: toggle)
    }

    func saveChanges(_ value: String) -> Bool {
      guard case let .model(type) = toggle.valueKey?.valueType else {
        assertionFailure()
        return false
      }

      guard let stringValue = value.nilIfEmpty,
            let dataValue = stringValue.data(using: .utf8),
            let model = try? decoder.decode(type, from: dataValue) else {
        return false
      }

      let newToggle = toggle.copy
      newToggle.value = model
      abTestingService.setOverriddenToggle(newToggle)

      return true
    }
  }
}
