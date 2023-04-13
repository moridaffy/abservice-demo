import Foundation

class FAPMainCollection: FAPICollection {
  private(set) var providers: [FAPIProvider] = []

  var backgroundColor: String { __backgroundColor }
  var _backgroundColor: FAPFlag<String> { ___backgroundColor }
  @FAPFlag(key: "ab_main_background_color", default: "FF0000")
  private var __backgroundColor: String

  var showLogo: Bool { __showLogo }
  var _showLogo: FAPFlag<Bool> { ___showLogo }
  @FAPFlag(key: "ab_main_show_logo", default: false)
  private var __showLogo: Bool

  var sinceYear: Int { __sinceYear }
  var _sinceYear: FAPFlag<Int> { ___sinceYear }
  @FAPFlag(key: "ab_main_since_year", default: 0)
  private var __sinceYear: Int

  var textConfig: MainTextConfig { __textConfig }
  var _textConfig: FAPFlag<MainTextConfig> { ___textConfig }
  @FAPFlag(key: "ab_main_text", default: MainTextConfig.empty)
  private var __textConfig: MainTextConfig

  required init() { }
}

extension FAPMainCollection: FAPIConfigurableWithProviders {
  func configure(with providers: [FAPIProvider]) {
    self.providers = providers

    Mirror(reflecting: self).children.lazy.forEach { child in
      if let configurable = child.value as? FAPIConfigurableWithProviders {
        configurable.configure(with: providers)
      }
    }
  }
}
