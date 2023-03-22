import Foundation
import UIKit

extension MainView {
  class Controller: UIViewController {
    private let logoImageView: UIImageView = {
      let imageView = UIImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.contentMode = .scaleAspectFit
      imageView.image = .init(named: "logo")
      return imageView
    }()

    private let titleLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textAlignment = .center
      label.numberOfLines = 0
      label.font = .systemFont(ofSize: 15.0, weight: .regular)
      return label
    }()

    private let subtitleLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textAlignment = .center
      label.numberOfLines = 0
      label.font = .systemFont(ofSize: 12.0, weight: .regular)
      return label
    }()

    private let debugMenuButton: UIButton = {
      let button = UIButton()
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle("Debug menu", for: .normal)
      button.setTitleColor(.systemBlue, for: .normal)
      button.setTitleColor(.systemBlue.withAlphaComponent(0.75), for: .highlighted)
      return button
    }()

    override func viewDidLoad() {
      super.viewDidLoad()

      setupLayout()
      setupActions()

      ABTestingService.shared.addObserver(self)
    }

    deinit {
      ABTestingService.shared.removeObserver(self)
    }
  }
}

private extension MainView.Controller {
  func setupLayout() {
    view.addSubview(logoImageView)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(debugMenuButton)

    view.addConstraints([
      logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
      logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImageView.heightAnchor.constraint(equalToConstant: 100.0),
      logoImageView.widthAnchor.constraint(equalToConstant: 100.0),

      titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16.0),
      titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0),
      titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0),
      subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      subtitleLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),

      debugMenuButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0),
      debugMenuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }

  func setupActions() {
    debugMenuButton.addTarget(self, action: #selector(debugMenuButtonTapped), for: .touchUpInside)
  }

  @objc func debugMenuButtonTapped() {
    let debugViewController = DebugView.build()
    navigationController?.pushViewController(debugViewController, animated: true)
  }
}

extension MainView.Controller: IABTestingServiceObserver {
  func didChangeConfig(_ service: IABTestingService) {
    if let backgroundColorCode = service.getStringValue(forKey: .mainBackgroundColor),
       let backgroundColor = UIColor(hex: backgroundColorCode) {
      view.backgroundColor = backgroundColor
    }

    if let showLogo = service.getBoolValue(forKey: .mainShowLogo) {
      logoImageView.isHidden = !showLogo
    }

    if let textConfig = service.getDecodableValue(forKey: .mainText, type: ABMainTextConfig.self) {
      titleLabel.text = textConfig.title
      subtitleLabel.text = textConfig.subtitle

      if let color = UIColor(hex: textConfig.textColor) {
        titleLabel.textColor = color
        subtitleLabel.textColor = color
      }
    }
  }
}
