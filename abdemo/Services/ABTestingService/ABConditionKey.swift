import Foundation

enum ABConditionKey: String {
  case minLaunchCount = "min_launch_count"
  case maxLaunchCount = "max_launch_count"
  case isPro = "is_user_pro"

  var valueType: ABValueType {
    switch self {
    case .minLaunchCount,
        .maxLaunchCount:
      return .int

    case .isPro:
      return .bool
    }
  }
}

enum ABConditionResolver {
  /// Resolves an array of AB conditions
  /// - Parameter conditions: an array of AB conditions
  /// - Returns: true if all passed conditions are fulfilled, otherwise returns false
  static func resolve(_ conditions: [ABConfig.Condition]) -> Bool {
    for condition in conditions {
      if !resolve(condition) {
        return false
      }
    }

    return true
  }

  static private func resolve(_ condition: ABConfig.Condition) -> Bool {
    guard let conditionKey = ABConditionKey(rawValue: condition.key) else {
      // ignoring unsupported keys to keep backward-compatibility
      return true
    }

    switch conditionKey {
    case .maxLaunchCount:
      guard let maxLaunchCount = condition.value as? Int else {
        // ignoring wrong configured conditions
        return true
      }
      // TODO: calculate real app launch count
      let appLaunchCount = 5
      return appLaunchCount <= maxLaunchCount

    case .minLaunchCount:
      guard let minLaunchCount = condition.value as? Int else {
        return true
      }
      // TODO: calculate real app launch count
      let appLaunchCount = 5
      return appLaunchCount >= minLaunchCount

    case .isPro:
      // TODO: get real user status
      let isUserPro = true
      return isUserPro
    }
  }
}
