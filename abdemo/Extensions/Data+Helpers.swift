import Foundation

extension Data {
  var prettyString: String? {
    do {
      let object = try JSONSerialization.jsonObject(with: self, options: [])
      let prettyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
      return String(data: prettyData, encoding: .utf8)
    } catch let error {
      print("error: \(error)")
      return nil
    }
  }
}
