import Foundation

protocol Observer: AnyObject { }

struct WeakObserver {
  let id: UUID

  weak var observer: Observer?

  init(id: UUID = .init(), observer: Observer) {
    self.id = id
    self.observer = observer
  }
}

extension WeakObserver: Equatable {
  static func == (lhs: WeakObserver, rhs: WeakObserver) -> Bool {
    lhs.id == rhs.id
  }
}

extension WeakObserver: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
