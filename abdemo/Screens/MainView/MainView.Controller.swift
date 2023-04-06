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

    private let sinceLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textAlignment = .center
      label.font = .italicSystemFont(ofSize: 16.0)
      label.textColor = .black.withAlphaComponent(0.75)
      return label
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

      WNDFAPLoader.shared.addObserver(self, for: FAPKeyPath.Main.allCases.compactMap { $0.keyPath })
    }

    deinit {
      WNDFAPLoader.shared.removeObserver(self)
    }
  }
}

private extension MainView.Controller {
  func setupLayout() {
    view.addSubview(logoImageView)
    view.addSubview(sinceLabel)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(debugMenuButton)

    view.addConstraints([
      logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
      logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImageView.heightAnchor.constraint(equalToConstant: 100.0),
      logoImageView.widthAnchor.constraint(equalToConstant: 100.0),

      sinceLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16.0),
      sinceLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
      sinceLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),

      titleLabel.topAnchor.constraint(equalTo: sinceLabel.bottomAnchor, constant: 32.0),
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
    let navigationController = UINavigationController(rootViewController: debugViewController)
    present(navigationController, animated: true)
  }
}

extension MainView.Controller: FAPILoaderObserver {
  func didChangeValues(_ loader: FAPILoader) {
    guard let loader = loader as? WNDFAPLoader else { return }
    if let backgroundColorCode = loader.main.backgroundColor,
       let backgroundColor = UIColor(hex: backgroundColorCode) {
      view.backgroundColor = backgroundColor
    }

    if let showLogo = loader.main.showLogo {
      logoImageView.isHidden = !showLogo
    }

    if let sinceYear = loader.main.sinceYear {
      sinceLabel.text = "Since \(sinceYear)"
    }

    if let textConfig = loader.main.textConfig {
      titleLabel.text = textConfig.title
      subtitleLabel.text = textConfig.subtitle

      let textColor = UIColor(hex: textConfig.textColor) ?? .black
      titleLabel.textColor = textColor
      subtitleLabel.textColor = textColor
    }
  }
}
