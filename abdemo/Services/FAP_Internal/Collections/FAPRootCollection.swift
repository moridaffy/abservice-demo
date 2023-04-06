import Foundation

struct FAPRootCollection: FAPICollection {
  @FAPCollection(key: "main")
  var main: FAPMainCollection
}
