import Foundation

struct FAPMainCollection: FAPICollection {
  @FAPFlag(keyPath: FAPKeyPath.Main.backgroundColor.keyPath, default: "FF0000")
  var backgroundColor: String?

  @FAPFlag(keyPath: FAPKeyPath.Main.showLogo.keyPath, default: false)
  var showLogo: Bool?

  @FAPFlag(keyPath: FAPKeyPath.Main.sinceYear.keyPath, default: 0)
  var sinceYear: Int?

  @FAPFlag(keyPath: FAPKeyPath.Main.textConfig.keyPath)
  var textConfig: MainTextConfig?
}
