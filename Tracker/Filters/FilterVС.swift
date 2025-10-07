import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: FilterViewControllerDelegate?
    private let currentFilter: TrackerFilter
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.dataSource = self
        tv.delegate = self
        tv.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Init
    init(currentFilter: TrackerFilter) {
        self.currentFilter = currentFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = NSLocalizedString("filters", comment: "Filters screen title")
        navigationController?.navigationBar.titleTextAttributes = [
            .font: Fonts.ysDisplayMedium16 ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
}

// MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FilterTableViewCell.identifier,
            for: indexPath
        ) as? FilterTableViewCell else {
            return UITableViewCell()
        }
        
        let filter = TrackerFilter.allCases[indexPath.row]
        let isSelected = shouldShowCheckmarkForFilter(filter)
        let isLastCell = indexPath.row == TrackerFilter.allCases.count - 1
        
        cell.configure(
            title: filter.title,
            isSelected: isSelected,
            isLastCell: isLastCell
        )
        
        return cell
    }
    
    private func shouldShowCheckmarkForFilter(_ filter: TrackerFilter) -> Bool {
        return filter.shouldShowCheckmark && filter == currentFilter
    }
}

// MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFilter = TrackerFilter.allCases[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
        
        dismiss(animated: true)
    }
}
