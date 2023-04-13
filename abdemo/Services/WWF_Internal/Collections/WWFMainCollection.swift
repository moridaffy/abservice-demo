import Foundation

class WWFMainCollection: WWFICollection {
  private(set) var providers: [WWFIProvider] = []

  var backgroundColor: String { __backgroundColor }
  var _backgroundColor: WWFFlag<String> { ___backgroundColor }
  @WWFFlag(key: "ab_main_background_color", default: "FF0000")
  private var __backgroundColor: String

  var showLogo: Bool { __showLogo }
  var _showLogo: WWFFlag<Bool> { ___showLogo }
  @WWFFlag(key: "ab_main_show_logo", default: false)
  private var __showLogo: Bool

  var sinceYear: Int { __sinceYear }
  var _sinceYear: WWFFlag<Int> { ___sinceYear }
  @WWFFlag(key: "ab_main_since_year", default: 0)
  private var __sinceYear: Int

  var textConfig: MainTextConfig { __textConfig }
  var _textConfig: WWFFlag<MainTextConfig> { ___textConfig }
  @WWFFlag(key: "ab_main_text", default: MainTextConfig.empty)
  private var __textConfig: MainTextConfig

  required init() { }
}

extension WWFMainCollection: WWFIConfigurableWithProviders {
  func configure(with providers: [WWFIProvider]) {
    self.providers = providers

    Mirror(reflecting: self).children.lazy.forEach { child in
      if let configurable = child.value as? WWFIConfigurableWithProviders {
        configurable.configure(with: providers)
      }
    }
  }
}
