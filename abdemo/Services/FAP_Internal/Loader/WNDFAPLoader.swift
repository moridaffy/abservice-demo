import Foundation

class WNDFAPLoader: FAPLoader<FAPRootCollection> {
  static var shared = WNDFAPLoader(FAPRootCollection.self,
                                   providers: WNDFAPLoader.defaultProviders)



  var main: FAPMainCollection {
    collection.main
  }
  var map: FAPMapCollection {
    collection.map
  }
}

extension WNDFAPLoader {
  static var defaultProviders: [FAPIProvider] = {
    let userDefaults = UserDefaults.standard
    let apiService = APIService.shared
    let logService = LogService.shared
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let resolver = FAPConditionResolver.shared

    return [
      FAPDebugProvider(userDefaults: userDefaults),
      FAPSettingsProvider(userDefaults: userDefaults),
      FAPRemoteProvider(apiService: apiService,
                        logService: logService,
                        userDefaults: userDefaults,
                        decoder: decoder,
                        encoder: encoder,
                        resolver: resolver),
      FAPLocalProvider(decoder: decoder,
                       resolver: resolver)
    ]
  }()
}
