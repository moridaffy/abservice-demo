import Foundation

protocol IAppSessionService {
  var numberOfLaunches: Int { get }
  var isUserPro: Bool { get }
}

class AppSessionService: IAppSessionService {
  static let shared = AppSessionService()

  let numberOfLaunches: Int
  let isUserPro: Bool

  private init() {
    let numberOfLaunches = (1...20).randomElement() ?? 5

    self.numberOfLaunches = numberOfLaunches
    self.isUserPro = numberOfLaunches % 2 == 0
  }
}
