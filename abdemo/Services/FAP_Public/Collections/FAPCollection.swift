import Foundation

protocol FAPICollection {
  init()
}

protocol FAPIParentCollection {
  var subCollection: FAPICollection? { get }
}

@propertyWrapper
class FAPCollection<Collection: FAPICollection>: Identifiable {
  let id: UUID = UUID()

  var wrappedValue: Collection

  private var key: String?

  private var loader = FAPLoaderWrapper()

  init(key: String? = nil) {
    self.key = key

    self.wrappedValue = Collection()
  }
}

extension FAPCollection: FAPIConfigurableWithLoader {
  func configure(with loader: FAPILoader) {
    self.loader.loader = loader

    Mirror(reflecting: wrappedValue).children.lazy.forEach { child in
      if let configurable = child.value as? FAPIConfigurableWithLoader {
        configurable.configure(with: loader)
      }
    }
  }
}

extension FAPCollection: FAPIParentCollection {
  var subCollection: FAPICollection? {
    wrappedValue
  }
}
