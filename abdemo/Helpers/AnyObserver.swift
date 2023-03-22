import Foundation

protocol Observer: AnyObject { }

struct AnyObserver {
  weak var observer: Observer?

  init(_ observer: Observer) {
    self.observer = observer
  }
}
