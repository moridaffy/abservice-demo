import Foundation

protocol IAPIService {
  func fetchConfig(completion: @escaping (Result<Configuration, Error>) -> Void)
}

class APIService {
  static let shared = APIService()

  private init() { }
}

extension APIService: IAPIService {
  func fetchConfig(completion: @escaping (Result<Configuration, Error>) -> Void) {
    completion(.failure(NSError(domain: "api", code: 0)))

//    guard let url = URL(string: "https://api.jsonbin.io/v3/b/642d578aebd26539d0a4f5a8?meta=false") else {
//      completion(.failure(NSError(domain: "api", code: 0)))
//      return
//    }
//
//    DispatchQueue.global().async {
//      do {
//        let data = try Data(contentsOf: url)
//        let config = try JSONDecoder().decode(Configuration.self, from: data)
//        DispatchQueue.main.async {
//          completion(.success(config))
//        }
//      } catch let error {
//        DispatchQueue.main.async {
//          completion(.failure(error))
//        }
//      }
//    }
  }
}
