import Foundation

extension Error {
  var debugDescription: String {
    (self as NSError).debugDescription
  }
}
