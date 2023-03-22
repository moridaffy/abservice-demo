import Foundation

protocol IABConfigProvider {
  var priority: ABConfigProviderPriority { get }
  var config: ABConfig? { get }

  func reset()

  func fetchConfig(completion: @escaping (Error?) -> Void)
  func getValue(for key: ABValueKey) -> Any?
}

extension IABConfigProvider {
  func reset() { }
}

enum ABConfigProviderPriority: Int {
  case low = 1
  case medium = 2
  case top = 3
}

extension ABConfigProviderPriority: Comparable {
  static func < (lhs: ABConfigProviderPriority, rhs: ABConfigProviderPriority) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}
