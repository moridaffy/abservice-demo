import Foundation
import UIKit

extension DebugView {
  class FlagCell: UITableViewCell {
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

    func update(model: DebugView.FlagCell.Model) {
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

private extension DebugView.FlagCell {
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

extension DebugView.FlagCell {
  enum ValueViewType {
    case value(String?)
    case info
    case none
  }
}

extension DebugView.FlagCell {
  struct Model {
    let flag: ABConfig.Flag

    let title: String
    let subtitle: String?
    let valueViewType: ValueViewType

    init(flag: ABConfig.Flag, valueViewType: ValueViewType) {
      self.flag = flag

      self.title = flag.key
      self.subtitle = flag.description
      self.valueViewType = valueViewType
    }
  }
}
