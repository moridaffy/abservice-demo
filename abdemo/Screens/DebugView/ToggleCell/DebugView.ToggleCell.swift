import Foundation
import UIKit

extension DebugView {
  class ToggleCell: UITableViewCell {
    private let titleLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textColor = .label
      label.font = .systemFont(ofSize: 17.0, weight: .regular)
      return label
    }()

    private let subtitleLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textColor = .tertiaryLabel
      label.font = .systemFont(ofSize: 14.0, weight: .regular)
      label.numberOfLines = 0
      return label
    }()

    private let valueLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textAlignment = .right
      label.textColor = .secondaryLabel
      label.font = .systemFont(ofSize: 17.0, weight: .regular)
      return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)

      setupLayout()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func update(model: DebugView.ToggleCell.Model) {
      titleLabel.text = model.title
      subtitleLabel.text = model.subtitle

      switch model.valueViewType {
      case let .value(value):
        valueLabel.text = value
        accessoryType = .none

      case .info:
        valueLabel.text = nil
        accessoryType = .disclosureIndicator

      case .none:
        valueLabel.text = nil
        accessoryType = .none
      }
    }
  }
}

private extension DebugView.ToggleCell {
  func setupLayout() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(valueLabel)

    contentView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0),
      subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      subtitleLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),

      valueLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 8.0),
      valueLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),
      valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])

    valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
  }
}

extension DebugView.ToggleCell {
  enum ValueViewType {
    case value(String?)
    case info
    case none
  }
}

extension DebugView.ToggleCell {
  struct Model {
    let toggle: ABConfig.Toggle

    let title: String
    let subtitle: String?
    let valueViewType: ValueViewType

    init(toggle: ABConfig.Toggle, valueViewType: ValueViewType) {
      self.toggle = toggle

      self.title = toggle.key
      self.subtitle = toggle.description
      self.valueViewType = valueViewType
    }
  }
}
