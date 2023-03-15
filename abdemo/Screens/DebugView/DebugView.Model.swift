import Foundation

extension DebugView {
  class Model {
    let abTestingService: IABTestingService

    private(set) var cellModels: [[ToggleCell.Model]] = [[]] {
      didSet {
        view?.reloadTableView()
      }
    }

    weak var view: DebugView.Controller?

    init(abTestingService: IABTestingService) {
      self.abTestingService = abTestingService

      reloadCellModels()
    }

    func reset() {
      abTestingService.reset()
    }

    func saveBoolValue(_ value: Bool, for toggle: ABConfig.Toggle) {
      overrideToggle(value: value, toggle: toggle)
    }

    func saveStringValue(_ value: String?, for toggle: ABConfig.Toggle) {
      overrideToggle(value: value?.nilIfEmpty, toggle: toggle)
    }

    func saveIntValue(_ value: String?, for toggle: ABConfig.Toggle) {
      var intValue: Int?
      if value?.nilIfEmpty == nil {
        intValue = nil
      } else {
        guard let value = Int(value ?? "") else {
          assertionFailure()
          return
        }
        intValue = value
      }

      overrideToggle(value: intValue, toggle: toggle)
    }

    func getReadableValue(for toggle: ABConfig.Toggle) -> String? {
      abTestingService.getReadableValue(for: toggle)
    }
  }
}

private extension DebugView.Model {
  func overrideToggle(value: Any?, toggle: ABConfig.Toggle) {
    if toggle.key == ABValueKey.overridingEnabled.rawValue {
      abTestingService.isOverridingEnabled = value as? Bool ?? false
    } else {
      let newToggle = toggle.copy
      newToggle.value = value
      abTestingService.setOverriddenToggle(newToggle)
    }

    reloadCellModels()
  }

  func reloadCellModels() {
    guard let localConfig = abTestingService.localConfig else {
      assertionFailure()
      return
    }

    func getValueViewType(for toggle: ABConfig.Toggle) -> DebugView.ToggleCell.ValueViewType {
      switch toggle.valueKey?.valueType {
      case .string, .int, .bool:
        return .value(getReadableValue(for: toggle))

      case .model:
        return .info

      default:
        return .none
      }
    }

    let overridingToggle = ABConfig.Toggle(key: ABValueKey.overridingEnabled.rawValue,
                                                      description: "Is overriding enabled",
                                                      value: abTestingService.isOverridingEnabled)
    var cellModels: [[DebugView.ToggleCell.Model]] = [
      [
        .init(toggle: overridingToggle, valueViewType: getValueViewType(for: overridingToggle))
      ]
    ]

    for collection in localConfig.collections {
      var models: [DebugView.ToggleCell.Model] = []
      for toggle in collection.toggles {
        models.append(.init(toggle: toggle, valueViewType: getValueViewType(for: toggle)))
      }
      cellModels.append(models)
    }

    self.cellModels = cellModels
  }
}
