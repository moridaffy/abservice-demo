import Foundation
import UIKit

extension DebugEditView {
  class Controller: UIViewController {
    private let textView: UITextView = {
      let textView = UITextView()
      textView.translatesAutoresizingMaskIntoConstraints = false
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
      setupTextView()
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

private extension DebugEditView.Controller {
  func setupLayout() {
    view.addSubview(textView)

    let textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0)
    self.textViewBottomConstraint = textViewBottomConstraint

    view.addConstraints([
      textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
      textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
      textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
      textViewBottomConstraint
    ])

    view.backgroundColor = .white
  }

  func setupNavigationBar() {
    title = viewModel.keyPath.key

    if navigationItem.rightBarButtonItem == nil {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
    }
  }

  func setupTextView() {
    textView.text = viewModel.read()
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
    viewModel.save(textView.text) { result in
      switch result {
      case .success:
        self.navigationController?.popViewController(animated: true)

      case let .failure(error):
        let alert = UIAlertController(title: "Error", message: "Failed to set new value: \((error.debugDescription))", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        self.present(alert, animated: true)
      }
    }
  }

  @objc private func keyboardWillShow(_ notification: NSNotification) {
    guard let userInfo = notification.userInfo,
          let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }

    textViewBottomConstraint?.constant = -(16.0 + height)
    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
    }
  }

  @objc private func keyboardWillHide() {
    textViewBottomConstraint?.constant = -16.0
    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
    }
  }
}
