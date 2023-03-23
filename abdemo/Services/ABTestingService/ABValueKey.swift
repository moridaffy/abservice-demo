import Foundation

enum ABValueKey: String {
  case overridingEnabled    = "ab_local_overriding_enabled"

  case mainBackgroundColor  = "ab_main_background_color"
  case mainShowLogo         = "ab_main_show_logo"
  case mainText             = "ab_main_text"

  case badgeCount           = "ab_badge_count"

  case sampleCondition      = "ab_sample_condition_flag"

  case mapLayers            = "ab_map_layers"

  var valueType: ABValueType {
    switch self {
    case .mainBackgroundColor:
      return .string

    case .mainShowLogo,
        .overridingEnabled,
        .sampleCondition:
      return .bool

    case .badgeCount:
      return .int

    case .mainText:
      return .model(ABMainTextConfig.self)

    case .mapLayers:
      return .model(ABMapLayersConfig.self)
    }
  }
}

enum ABValueType: Equatable {
  case string
  case int
  case bool
  case model(Codable.Type)

  static func == (lhs: ABValueType, rhs: ABValueType) -> Bool {
    switch (lhs, rhs) {
    case (.string, .string),
      (.int, .int),
      (.bool, .bool):
      return true

    case let (.model(lhsType), .model(rhsType)):
      return lhsType == rhsType

    default:
      return false
    }
  }
}
