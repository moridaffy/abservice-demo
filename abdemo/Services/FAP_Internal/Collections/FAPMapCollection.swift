import Foundation

class FAPMapCollection: FAPICollection {
  private(set) var providers: [FAPIProvider] = []

  var mapLayers: [String] { __mapLayers }
  var _mapLayers: FAPFlag<[String]> { ___mapLayers }
  @FAPFlag(key: "ab_map_layers", default: [])
  private var __mapLayers: [String]

  required init() { }
}

extension FAPMapCollection: FAPIConfigurableWithProviders {
  func configure(with providers: [FAPIProvider]) {
    self.providers = providers

    Mirror(reflecting: self).children.lazy.forEach { child in
      if let configurable = child.value as? FAPIConfigurableWithProviders {
        configurable.configure(with: providers)
      }
    }
  }
}
