import Foundation
import UIKit

extension UIColor {
  convenience init?(hex: String) {
    var hex = hex
    if hex.hasPrefix("#") {
      hex.removeFirst()
    }

    if hex.count == 6 {
      hex += "ff"
    }

    guard hex.count == 8 else { return nil }

    let scanner = Scanner(string: hex)
    var hexNumber: UInt64 = 0

    guard scanner.scanHexInt64(&hexNumber) else { return nil }

    self.init(red: CGFloat((hexNumber & 0xff000000) >> 24) / 255,
              green: CGFloat((hexNumber & 0x00ff0000) >> 16) / 255,
              blue: CGFloat((hexNumber & 0x0000ff00) >> 8) / 255,
              alpha: CGFloat(hexNumber & 0x000000ff) / 255)
  }
}
