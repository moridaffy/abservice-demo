import Foundation

protocol ILogService {
  func setIdentity(forKey key: String, value: String)
}

class LogService: ILogService {
  static let shared = LogService()

  func setIdentity(forKey key: String, value: String) {
    print("💭 Setting identity: \(key) - \(value)")
  }
}
