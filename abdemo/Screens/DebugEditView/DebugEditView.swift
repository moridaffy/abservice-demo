import Foundation

enum DebugEditView {
  static func build(key: String, value: WWFValueType, provider: WWFISettableProvider?) -> Controller {
    let model = Model(key: key, value: value, provider: provider)
    let controller = Controller(viewModel: model)
    return controller
  }
}
