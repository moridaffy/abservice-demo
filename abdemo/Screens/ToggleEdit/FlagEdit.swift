import Foundation

enum FlagEdit {
  static func build(abTestingService: IABTestingService = ABTestingService.shared, flag: ABConfig.Flag) -> Controller {
    let model = Model(abTestingService: abTestingService, flag: flag)
    let controller = Controller(viewModel: model)
    return controller
  }
}
