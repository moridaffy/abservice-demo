import Foundation

protocol FAPIConfigurableWithLoader {
  func configure(with loader: FAPILoader)
}

protocol FAPILoaderObserver: Observer {
  func didChangeValues(_ loader: FAPILoader)
}

protocol FAPILoader: AnyObject {
  var rootCollection: FAPICollection { get }
  var providers: [FAPIProvider] { get }

  func addObserver(_ observer: FAPILoaderObserver, for keys: [FAPKeyPath])
  func removeObserver(_ observer: FAPILoaderObserver)

  func didChangeValue(keys: [FAPKeyPath])
}

extension FAPILoader {
  func addObserver(_ observer: FAPILoaderObserver) {
    addObserver(observer, for: [])
  }
}

class FAPLoader<Collection: FAPICollection>: FAPILoader {
  private(set) var providers: [FAPIProvider]
  var rootCollection: FAPICollection { collection }

  let collection: Collection

  private var observers: [WeakObserver: [FAPKeyPath]] = [:]

  init(_ collectionType: Collection.Type,
       providers: [FAPIProvider]) {
    self.collection = collectionType.init()
    self.providers = providers

    initializeCollectionObjects()
    linkWithProviders()
  }

  func addObserver(_ observer: FAPILoaderObserver, for keys: [FAPKeyPath]) {
    if observers.contains(where: { $0.key.observer === observer }) {
      assertionFailure()
      return
    }

    observers[.init(observer: observer)] = keys
    observer.didChangeValues(self)
  }

  func removeObserver(_ observer: FAPILoaderObserver) {
    guard let observer = observers.first(where: { $0.key.observer === observer }) else {
      assertionFailure()
      return
    }

    observers.removeValue(forKey: observer.key)
  }

  func didChangeValue(keys: [FAPKeyPath]) {
    var observersToNotify: [FAPILoaderObserver] = []

    for observer in observers {
      for observedKey in observer.value {
        if keys.contains(observedKey) {
          if let observer = observer.key.observer as? FAPILoaderObserver {
            observersToNotify.append(observer)
          }
          continue
        }
      }
    }

    observersToNotify.forEach { $0.didChangeValues(self) }
  }
}

private extension FAPLoader {
  func initializeCollectionObjects() {
    Mirror(reflecting: collection).children.lazy.forEach { child in
      if let configurable = child.value as? FAPIConfigurableWithLoader {
        configurable.configure(with: self)
      }
    }
  }

  func linkWithProviders() {
    for i in 0..<providers.count {
      providers[i].loader = self
    }
  }
}
