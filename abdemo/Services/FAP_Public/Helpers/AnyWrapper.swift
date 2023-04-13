import Foundation

class AnyWrapper: Hashable {
  static func == (lhs: AnyWrapper, rhs: AnyWrapper) -> Bool {
    lhs.hashValue == rhs.hashValue
  }

  var value: AnyHashable?

  init(_ value: AnyHashable?) {
    self.value = value
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}
