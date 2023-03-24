import Foundation

protocol Observer: AnyObject { }

struct AnyObserver {
  let id: UUID

  weak var observer: Observer?

  init(_ observer: Observer) {
    self.id = .init()
    self.observer = observer
  }
}

extension AnyObserver: Hashable {
  static func == (lhs: AnyObserver, rhs: AnyObserver) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
