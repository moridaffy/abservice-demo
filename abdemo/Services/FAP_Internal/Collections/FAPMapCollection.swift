import Foundation

struct FAPMapCollection: FAPICollection {
  @FAPFlag(keyPath: FAPKeyPath.Map.mapLayers.keyPath)
  var mapLayers: [String]?
}
