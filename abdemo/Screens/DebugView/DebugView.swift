import Foundation

enum DebugView {
  static func build(collection: WWFICollection) -> Controller {
    let model = Model(collection: collection)
    let controller = Controller(viewModel: model)
    return controller
  }
}
