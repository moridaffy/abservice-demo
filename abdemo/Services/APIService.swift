import Foundation

class APIService {
  static let shared = APIService()

  func fetchConfig(completionHandler: @escaping (ABConfig?) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      completionHandler(nil)
    }
  }
}
