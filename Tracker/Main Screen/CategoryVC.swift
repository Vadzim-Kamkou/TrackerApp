import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CategoryViewControllerDelegate?
    private var viewModel: CategoryViewModelProtocol
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle   = .none
        tv.dataSource = self
        tv.delegate   = self
        tv.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(resource: .noTrackers))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = Fonts.ysDisplayMedium12 ?? UIFont.systemFont(ofSize: 12)
        label.textColor = .appGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10)
        ])
        
        return view
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = Fonts.ysDisplayMedium16 ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .appBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init(trackerCategoryStore: TrackerCategoryStore?) {
        self.viewModel = CategoryViewModel(trackerCategoryStore: trackerCategoryStore)
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(viewModel: CategoryViewModelProtocol) {
        self.init(trackerCategoryStore: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupBindings()
        viewModel.loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCategories()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(addCategoryButton)
        
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: Fonts.ysDisplayMedium16 ?? UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(resource: .appBlack)
        ]
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        title = "Категория"
    }
    
    // MARK: - MVVM
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onEmptyStateChanged = { [weak self] isEmpty in
            DispatchQueue.main.async {
                self?.emptyStateView.isHidden = !isEmpty
                self?.tableView.isHidden = isEmpty
            }
        }
        
        viewModel.onError = { errorMessage in
            DispatchQueue.main.async {
                print("Ошибка в CategoryViewController: \(errorMessage)")
            }
        }
    }
    
    // MARK: - Public Methods
    func setPreselectedCategory(title: String?) {
        viewModel.setPreselectedCategory(title: title)
    }
    
    @objc private func addCategoryTapped() {
        let categoryNewVC = CategoryNewViewController()
        categoryNewVC.delegate = self
        let navigationController = UINavigationController(rootViewController: categoryNewVC)
        present(navigationController, animated: true)
        
    }
}

// MARK: - Extension VC Delegate
extension CategoryViewController: CategoryNewViewControllerDelegate {
    func didCreateCategory(_ category: TrackerCategory) {
        viewModel.addCategory(category)
        
        if let selectedCategory = viewModel.getSelectedCategory() {
            delegate?.didSelectCategory(selectedCategory)
        }
        dismiss(animated: true)
    }
}

// MARK: - Extension Table DataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCategoriesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let title = viewModel.getCategoryTitle(at: indexPath.row)
        let isSelected = viewModel.isSelected(at: indexPath.row)
        let isLast = indexPath.row == viewModel.getCategoriesCount() - 1
        
        cell.configure(title: title, isSelected: isSelected, isLast: isLast)
        
        return cell
    }
}

// MARK: - Extension Table Delegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        
        if let selectedCategory = viewModel.getSelectedCategory() {
            delegate?.didSelectCategory(selectedCategory)
        }
        dismiss(animated: true)
    }
}
