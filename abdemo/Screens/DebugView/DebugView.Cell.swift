import Foundation
import UIKit

extension DebugView {
  class Cell: UITableViewCell {
    private let titleLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = .systemFont(ofSize: 16.0, weight: .regular)
      label.textColor = UIColor.black
      label.numberOfLines = 0
      return label
    }()

    private let valueLabel: UILabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = .systemFont(ofSize: 14.0, weight: .regular)
      label.textColor = UIColor.black.withAlphaComponent(0.5)
      label.numberOfLines = 0
      return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)

      setupLayout()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: Model) {
      self.titleLabel.text = viewModel.keyPath.key
      self.valueLabel.text = viewModel.value.description
    }
  }
}

private extension DebugView.Cell {
  func setupLayout() {
    contentView.addSubview(titleLabel)
    contentView.addSubview(valueLabel)

    contentView.addConstraints([
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
      titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.0),
      titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.0),

      valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0),
      valueLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
      valueLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
      valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0)
    ])
  }
}

extension DebugView.Cell {
  class Model {
    let keyPath: FAPKeyPath
    let value: FAPValueType

    init(keyPath: FAPKeyPath, value: FAPValueType) {
      self.keyPath = keyPath
      self.value = value
    }
  }
}
