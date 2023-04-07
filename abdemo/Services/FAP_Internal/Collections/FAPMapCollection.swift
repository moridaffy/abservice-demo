import Foundation

struct FAPMapCollection: FAPICollection {
  @FAPFlag(key: "ab_map_layers", default: [])
  var mapLayers: [String]
}
