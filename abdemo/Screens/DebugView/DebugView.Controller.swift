import Foundation
import UIKit

extension DebugView {
  class Controller: UIViewController {
    private let tableView: UITableView = {
      let tableView = UITableView(frame: .zero, style: .insetGrouped)
      tableView.translatesAutoresizingMaskIntoConstraints = false
      tableView.register(DebugView.FlagCell.self, forCellReuseIdentifier: "cell")
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

      setupNavigationBar()

      viewModel.view = self
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
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  func setupNavigationBar() {
    title = "Debug menu"

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

    tableView.contentInset = view.safeAreaInsets
  }

  func handleFlagTap(_ flag: ABConfig.Flag) {
    guard let valueType = flag.valueKey?.valueType else { return }

    if case .model = valueType {
      let flagEdit = FlagEdit.build(flag: flag)
      navigationController?.pushViewController(flagEdit, animated: true)
      return
    }

    let alert = UIAlertController(title: "Edit value", message: flag.key, preferredStyle: .alert)
    alert.addAction(.init(title: "Cancel", style: .cancel))

    switch valueType {
    case .string, .int:
      alert.addTextField { textField in
        textField.placeholder = "value"
        textField.text = self.viewModel.getReadableValue(for: flag)
        textField.keyboardType = valueType == .string ? .default : .numberPad
      }
      alert.addAction(.init(title: "Save", style: .default, handler: { _ in
        let newValue = alert.textFields?.first?.text
        if valueType == .string {
          self.viewModel.saveStringValue(newValue, for: flag)
        } else {
          self.viewModel.saveIntValue(newValue, for: flag)
        }
      }))

    case .bool:
      alert.addAction(.init(title: "True", style: .default, handler: { _ in
        self.viewModel.saveBoolValue(true, for: flag)
      }))
      alert.addAction(.init(title: "False", style: .default, handler: { _ in
        self.viewModel.saveBoolValue(false, for: flag)
      }))

    default:
      break
    }

    present(alert, animated: true)
  }


  @objc func resetButtonTapped() {
    viewModel.reset()
  }

  @objc func doneButtonTapped() {
    navigationController?.popViewController(animated: true)
  }
}

extension DebugView.Controller: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    min(50.0, UITableView.automaticDimension)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    handleFlagTap(viewModel.cellModels[indexPath.section][indexPath.row].flag)
  }
}

extension DebugView.Controller: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    viewModel.cellModels.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return nil
    }
    return viewModel.abTestingService.localConfig?.collections[section - 1].name
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.cellModels[section].count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DebugView.FlagCell else {
      assertionFailure()
      return UITableViewCell()
    }

    cell.update(model: viewModel.cellModels[indexPath.section][indexPath.row])

    return cell
  }
}
