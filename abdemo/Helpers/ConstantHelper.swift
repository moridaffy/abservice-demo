import Foundation

enum ConstantHelper {
  static var buildType: BuildType {
    #if DEBUG
    return .debug
    #endif

    if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
      return .testFlight
    } else {
      return .appStore
    }
  }
}

extension ConstantHelper {
  enum BuildType {
    case testFlight
    case appStore
    case debug
  }
}
