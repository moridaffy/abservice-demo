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

    private let sessionLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textAlignment = .center
      label.font = .systemFont(ofSize: 16.0, weight: .regular)
      label.numberOfLines = 0
      return label
    }()

    private let mapLayersLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textAlignment = .center
      label.font = .systemFont(ofSize: 16.0, weight: .regular)
      label.numberOfLines = 0
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
      setupContent()

      FAPRootCollection.shared._main.subscribe(self) { [weak self] collection in
        if let backgroundColor = UIColor(hex: collection.backgroundColor) {
          self?.view.backgroundColor = backgroundColor
        }

        self?.logoImageView.isHidden = collection.showLogo

        self?.sinceLabel.text = "Since \(collection.sinceYear)"

        let config = collection.textConfig
        self?.titleLabel.text = config.title
        self?.subtitleLabel.text = config.subtitle

        let textColor = UIColor(hex: config.textColor) ?? .black
        self?.titleLabel.textColor = textColor
        self?.subtitleLabel.textColor = textColor
      }

      FAPRootCollection.shared.map._mapLayers.subscribe(self) { [weak self] newValue in
        var parts = ["Available map layers"]
        if newValue.isEmpty {
          parts.append("none")
        } else {
          parts.append(contentsOf: newValue)
        }
        self?.mapLayersLabel.text = parts.joined(separator: "\n")
      }
    }
  }
}

private extension MainView.Controller {
  func setupLayout() {
    view.addSubview(logoImageView)
    view.addSubview(sinceLabel)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(sessionLabel)
    view.addSubview(mapLayersLabel)
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

      sessionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32.0),
      sessionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      sessionLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),

      mapLayersLabel.topAnchor.constraint(equalTo: sessionLabel.bottomAnchor, constant: 16.0),
      mapLayersLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      mapLayersLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),

      debugMenuButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0),
      debugMenuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }

  func setupActions() {
    debugMenuButton.addTarget(self, action: #selector(debugMenuButtonTapped), for: .touchUpInside)
  }

  func setupContent() {
    let session = AppSessionService.shared
    sessionLabel.text = [
      "number of launches: \(session.numberOfLaunches)",
      "user is pro: \(session.isUserPro)"
    ]
      .joined(separator: "\n")
  }

  @objc func debugMenuButtonTapped() {
    let debugViewController = DebugView.build(collection: FAPRootCollection.shared)
    let navigationController = UINavigationController(rootViewController: debugViewController)
    present(navigationController, animated: true)
  }
}
