import Foundation

enum DebugView {
  static func build(collection: FAPICollection) -> Controller {
    let model = Model(collection: collection)
    let controller = Controller(viewModel: model)
    return controller
  }
}
