import Foundation
import UIKit

extension FlagEdit {
  class Controller: UIViewController {
    private let textView: UITextView = {
      let textView = UITextView()
      textView.translatesAutoresizingMaskIntoConstraints = false
      textView.layer.cornerRadius = 4.0
      textView.layer.borderColor = UIColor.black.cgColor
      textView.layer.borderWidth = 1.0
      return textView
    }()

    private var textViewBottomConstraint: NSLayoutConstraint?

    private let viewModel: Model

    init(viewModel: Model) {
      self.viewModel = viewModel

      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
      super.viewDidLoad()

      setupLayout()

      textView.text = viewModel.getReadableValue()
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      setupNavigationBar()
      setupKeyboardNotifications(subscribe: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)

      view.endEditing(true)
      setupKeyboardNotifications(subscribe: false)
    }
  }
}

private extension FlagEdit.Controller {
  func setupLayout() {
    view.addSubview(textView)

    let textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0)
    self.textViewBottomConstraint = textViewBottomConstraint

    view.addConstraints([
      textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
      textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
      textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0),
      textViewBottomConstraint
    ])

    view.backgroundColor = .white
  }

  func setupNavigationBar() {
    title = viewModel.flag.key

    if navigationItem.rightBarButtonItem == nil {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
    }
  }

  func setupKeyboardNotifications(subscribe: Bool) {
    if subscribe {
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    } else {
      NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
  }

  @objc func saveButtonTapped() {
    view.endEditing(true)

    if viewModel.saveChanges(textView.text ?? "") {
      navigationController?.popViewController(animated: true)
      return
    }

    let alertController = UIAlertController(title: "Error", message: "Failed to update flag, probably entered JSON is not valid", preferredStyle: .alert)
    alertController.addAction(.init(title: "OK", style: .default))
    present(alertController, animated: true)
  }

  @objc private func keyboardWillShow(_ notification: NSNotification) {
    guard let userInfo = notification.userInfo,
          let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }

    textViewBottomConstraint?.constant = -(keyboardHeight + 8.0)
  }

  @objc private func keyboardWillHide() {
    textViewBottomConstraint?.constant = -8.0
  }
}
