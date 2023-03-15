import Foundation
import UIKit

enum DebugView {
  static func build(abTestingService: IABTestingService = ABTestingService.shared) -> Controller {
    let model = Model(abTestingService: abTestingService)
    let controller = Controller(viewModel: model)
    return controller
  }
}
