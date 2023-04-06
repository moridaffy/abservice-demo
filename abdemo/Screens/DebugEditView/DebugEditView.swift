import Foundation

enum DebugEditView {
  static func build(keyPath: FAPKeyPath, value: FAPValueType, provider: FAPIProvider?) -> Controller {
    let model = Model(keyPath: keyPath, value: value, provider: provider)
    let controller = Controller(viewModel: model)
    return controller
  }
}
