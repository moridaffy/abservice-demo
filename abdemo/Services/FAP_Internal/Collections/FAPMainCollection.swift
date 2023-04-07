import Foundation

struct FAPMainCollection: FAPICollection {
  @FAPFlag(key: "ab_main_background_color", default: "FF0000")
  var backgroundColor: String

  @FAPFlag(key: "ab_main_show_logo", default: false)
  var showLogo: Bool

  @FAPFlag(key: "ab_main_since_year", default: 0)
  var sinceYear: Int

  @FAPFlag(key: "ab_main_text", default: MainTextConfig.empty)
  var textConfig: MainTextConfig
}
