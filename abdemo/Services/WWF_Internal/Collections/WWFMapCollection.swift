import Foundation

class WWFMapCollection: WWFICollection {
  private(set) var providers: [WWFIProvider] = []

  var mapLayers: [String] { __mapLayers }
  var _mapLayers: WWFFlag<[String]> { ___mapLayers }
  @WWFFlag(key: "ab_map_layers", default: [])
  private var __mapLayers: [String]

  required init() { }
}

extension WWFMapCollection: WWFIConfigurableWithProviders {
  func configure(with providers: [WWFIProvider]) {
    self.providers = providers

    Mirror(reflecting: self).children.lazy.forEach { child in
      if let configurable = child.value as? WWFIConfigurableWithProviders {
        configurable.configure(with: providers)
      }
    }
  }
}
