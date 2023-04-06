import Foundation
import UIKit

extension DebugView {
  class Controller: UIViewController {
    private let tableView: UITableView = {
      let tableView = UITableView(frame: .zero, style: .insetGrouped)
      tableView.translatesAutoresizingMaskIntoConstraints = false

      tableView.register(DebugView.Cell.self, forCellReuseIdentifier: "cell")

      return tableView
    }()

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
      setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      viewModel.view = self

      setupNavigationBar()
    }

    func reloadTableView() {
      tableView.reloadData()
    }
  }
}

private extension DebugView.Controller {
  func setupLayout() {
    view.addSubview(tableView)

    view.addConstraints([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    view.backgroundColor = .white
  }

  func setupNavigationBar() {
    title = "Debug view"

    if navigationItem.leftBarButtonItem == nil {
      navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetButtonTapped))
    }
    if navigationItem.rightBarButtonItem == nil {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
    }
  }

  func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
  }

  func handleFlagTap(keyPath: FAPKeyPath, value: FAPValueType) {
    let alert = UIAlertController(title: "Set new value", message: keyPath.path, preferredStyle: .alert)
    alert.addAction(.init(title: "Cancel", style: .cancel))

    switch value {
    case let .integer(value):
      alert.addTextField(text: "\(value)", keyboardType: .numberPad)
      alert.addAction(.init(title: "Save", style: .default) { _ in
        if let text = alert.textFields?.first?.text?.nilIfEmpty,
           let value = Int(text) {
          self.viewModel.setValue(.integer(value), for: keyPath)
        } else {
          self.viewModel.setValue(.none, for: keyPath)
        }
      })

    case let .double(value):
      alert.addTextField(text: "\(value)", keyboardType: .decimalPad)
      alert.addAction(.init(title: "Save", style: .default) { _ in
        if let text = alert.textFields?.first?.text?.nilIfEmpty,
           let value = Double(text) {
          self.viewModel.setValue(.double(value), for: keyPath)
        } else {
          self.viewModel.setValue(.none, for: keyPath)
        }
      })

    case let .float(value):
      alert.addTextField(text: "\(value)", keyboardType: .decimalPad)
      alert.addAction(.init(title: "Save", style: .default) { _ in
        if let text = alert.textFields?.first?.text?.nilIfEmpty,
           let value = Float(text) {
          self.viewModel.setValue(.float(value), for: keyPath)
        } else {
          self.viewModel.setValue(.none, for: keyPath)
        }
      })

    case let .string(value):
      alert.addTextField(text: value)
      alert.addAction(.init(title: "Save", style: .default) { _ in
        if let text = alert.textFields?.first?.text?.nilIfEmpty {
          self.viewModel.setValue(.string(text), for: keyPath)
        } else {
          self.viewModel.setValue(.none, for: keyPath)
        }
      })

    case .boolean:
      alert.addAction(.init(title: "true", style: .default) { _ in
        self.viewModel.setValue(.boolean(true), for: keyPath)
      })
      alert.addAction(.init(title: "false", style: .default) { _ in
        self.viewModel.setValue(.boolean(false), for: keyPath)
      })

    case .model(_):
      let debugEditView = DebugEditView.build(keyPath: keyPath, value: value, provider: viewModel.debugProvider)
      navigationController?.pushViewController(debugEditView, animated: true)
      return

    case .data(_):
      return

    case .array(_):
      return

    case .none:
      return
    }

    present(alert, animated: true)
  }

  @objc func resetButtonTapped() {
    viewModel.reset()
  }

  @objc func doneButtonTapped() {
    dismiss(animated: true)
  }
}

extension DebugView.Controller: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let viewModel = viewModel.sections[indexPath.section].viewModels[indexPath.row]
    handleFlagTap(keyPath: viewModel.keyPath, value: viewModel.value)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    max(50.0, UITableView.automaticDimension)
  }

  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let keyPath = viewModel.sections[indexPath.section].viewModels[indexPath.row].keyPath
    let deleteAction = UIContextualAction(style: .normal, title: "Reset") { _, _, completion in
      self.viewModel.resetValue(forKey: keyPath)
      completion(true)
    }
    deleteAction.backgroundColor = .orange
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}

extension DebugView.Controller: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    viewModel.sections.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    viewModel.sections[section].title
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.sections[section].viewModels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DebugView.Cell else {
      return UITableViewCell()
    }

    let viewModel = viewModel.sections[indexPath.section].viewModels[indexPath.row]
    cell.update(viewModel: viewModel)

    return cell
  }
}
