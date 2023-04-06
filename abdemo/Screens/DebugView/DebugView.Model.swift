import Foundation

extension DebugView {
  class Model {
    private let loader: FAPILoader

    weak var view: Controller?

    private(set) var sections: [Section] = [] {
      didSet {
        view?.reloadTableView()
      }
    }

    var debugProvider: FAPIProvider? {
      // TODO: придумать более элегантный способ получения нужного провайдера
      loader.providers.first(where: { $0.name.lowercased().contains("debug") })
    }

    init(loader: FAPILoader) {
      self.loader = loader
      generateFeatures()
    }

    func reset() {
      debugProvider?.reset()
      generateFeatures()
    }

    func setValue(_ value: FAPValueType, for keyPath: FAPKeyPath) {
      debugProvider?.setValue(value.value, forKey: keyPath)
      generateFeatures()
    }
  }
}

private extension DebugView.Model {
  func generateFeatures() {
    var sections: [Section] = []

    let rootCollection = self.loader.rootCollection
    collectionLoop: for collection in Mirror(reflecting: rootCollection).children.lazy {
      guard let label = collection.label?.nilIfEmpty else { continue collectionLoop }
      let title = label.hasPrefix("_") ? String(label.dropFirst()) : label

      guard let parentCollection = collection.value as? FAPIParentCollection,
            let subCollection = parentCollection.subCollection else { continue collectionLoop }

      var viewModels: [DebugView.Cell.Model] = []
      flagLoop: for flag in Mirror(reflecting: subCollection).children.lazy {
        guard let value = flag.value as? FAPIFlag else { continue flagLoop }
        viewModels.append(.init(keyPath: value.keyPath, value: value.value ?? .none))
      }

      sections.append(.init(title: title, viewModels: viewModels))
    }

    self.sections = sections
  }
}

extension DebugView.Model {
  struct Section {
    let title: String
    let viewModels: [DebugView.Cell.Model]
  }
}
