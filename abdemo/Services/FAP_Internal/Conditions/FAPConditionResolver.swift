import Foundation

class FAPConditionResolver {
  static let shared = FAPConditionResolver()

  private let appSessionService: IAppSessionService

  private init(appSessionService: IAppSessionService = AppSessionService.shared) {
    self.appSessionService = appSessionService
  }

  func resolve(_ conditions: [Configuration.Condition]) -> Bool {
    for condition in conditions {
      if !resolve(condition) {
        return false
      }
    }

    return true
  }

  func resolve(_ condition: Configuration.Condition) -> Bool {
    guard let conditionKey = FAPConditionType(rawValue: condition.key) else {
      // allowing unknown conditions to keep backward compatibility
      return true
    }

    switch conditionKey {
    case .minAppLaunchCount:
      return resolveMinAppLaunchCount(with: condition.value)

    case .maxAppLaunchCount:
      return resolveMaxAppLaunchCount(with: condition.value)

    case .isPro:
      return resolveIsPro()
    }
  }
}

private extension FAPConditionResolver {
  func resolveMinAppLaunchCount(with value: Any?) -> Bool {
    guard let value = value as? Int else {
      // allowing unknown conditions to keep backward compatibility
      return true
    }

    return appSessionService.numberOfLaunches > value
  }

  func resolveMaxAppLaunchCount(with value: Any?) -> Bool {
    guard let value = value as? Int else {
      // allowing unknown conditions to keep backward compatibility
      return true
    }

    return appSessionService.numberOfLaunches < value
  }

  func resolveIsPro() -> Bool {
    return appSessionService.isUserPro
  }
}
