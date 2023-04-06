import Foundation
import UIKit

extension UIAlertController {
  func addTextField(text: String? = nil, keyboardType: UIKeyboardType = .default) {
    addTextField { textField in
      textField.text = text
      textField.keyboardType = keyboardType
    }
  }
}
