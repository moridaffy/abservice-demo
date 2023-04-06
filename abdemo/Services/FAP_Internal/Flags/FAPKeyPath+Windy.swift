import Foundation

// MARK: - Main

extension FAPKeyPath {
  enum Main: String, CaseIterable {
    case backgroundColor = "ab_main_background_color"
    case showLogo = "ab_main_show_logo"
    case sinceYear = "ab_main_since_year"
    case textConfig = "ab_main_text"

    var keyPath: FAPKeyPath {
      FAPKeyPath(collection: "main", key: rawValue)
    }
  }
}

// MARK: - Map

extension FAPKeyPath {
  enum Map: String, CaseIterable {
    case mapLayers = "ab_map_layers"

    var keyPath: FAPKeyPath {
      FAPKeyPath(collection: "map", key: rawValue)
    }
  }
}
