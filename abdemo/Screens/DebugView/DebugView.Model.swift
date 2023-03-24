import Foundation

extension DebugView {
  class Model {
    let abTestingService: IABTestingService

    private(set) var cellModels: [[FlagCell.Model]] = [[]] {
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
      reloadCellModels()
    }

    func saveBoolValue(_ value: Bool, for flag: ABConfig.Flag) {
      overrideFlag(value: value, flag: flag)
    }

    func saveStringValue(_ value: String?, for flag: ABConfig.Flag) {
      overrideFlag(value: value?.nilIfEmpty, flag: flag)
    }

    func saveIntValue(_ value: String?, for flag: ABConfig.Flag) {
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

      overrideFlag(value: intValue, flag: flag)
    }

    func getReadableValue(for flag: ABConfig.Flag) -> String? {
      if flag.key == ABValueKey.overridingEnabled.rawValue {
        return "\(ABTestingService.shared.isOverridingEnabled)"
      }

      guard let valueKey = flag.valueKey else { return "error" }
      guard let value = abTestingService.getValue(forKey: valueKey) else { return "nil" }
      return "\(value)"
    }
  }
}

private extension DebugView.Model {
  func overrideFlag(value: Any?, flag: ABConfig.Flag) {
    if flag.key == ABValueKey.overridingEnabled.rawValue {
      abTestingService.isOverridingEnabled = value as? Bool ?? false
    } else if let key = flag.valueKey {
      abTestingService.setOverriddenFlag(forKey: key, value: value)
    } else {
      return
    }

    reloadCellModels()
  }

  func reloadCellModels() {
    guard let localConfig = abTestingService.localConfig else {
      assertionFailure()
      return
    }

    func getValueViewType(for flag: ABConfig.Flag) -> DebugView.FlagCell.ValueViewType {
      switch flag.valueKey?.valueType {
      case .string, .int, .bool:
        return .value(getReadableValue(for: flag))

      case .model:
        return .info

      default:
        return .none
      }
    }

    let overridingFlag = ABConfig.Flag(key: ABValueKey.overridingEnabled.rawValue,
                                                      description: "Is overriding enabled",
                                                      value: abTestingService.isOverridingEnabled)
    var cellModels: [[DebugView.FlagCell.Model]] = [
      [
        .init(flag: overridingFlag, valueViewType: getValueViewType(for: overridingFlag))
      ]
    ]

    for collection in localConfig.collections {
      var models: [DebugView.FlagCell.Model] = []
      for flag in collection.flags {
        models.append(.init(flag: flag, valueViewType: getValueViewType(for: flag)))
      }
      cellModels.append(models)
    }

    self.cellModels = cellModels
  }
}
