import Foundation

enum DebugView {
  static func build(loader: FAPILoader = WNDFAPLoader.shared) -> Controller {
    let model = Model(loader: loader)
    let controller = Controller(viewModel: model)
    return controller
  }
}
