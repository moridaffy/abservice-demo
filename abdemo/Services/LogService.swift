import Foundation

protocol ILogService: AnyObject {
  func setIdentity(identity: String, value: Any?)
}

class LogService: ILogService {
  static let shared = LogService()

  func setIdentity(identity: String, value: Any?) {
    // TODO
  }
}
