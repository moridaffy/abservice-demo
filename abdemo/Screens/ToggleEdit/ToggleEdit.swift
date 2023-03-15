import Foundation

enum ToggleEdit {
  static func build(abTestingService: IABTestingService = ABTestingService.shared, toggle: ABConfig.Toggle) -> Controller {
    let model = Model(abTestingService: abTestingService, toggle: toggle)
    let controller = Controller(viewModel: model)
    return controller
  }
}
