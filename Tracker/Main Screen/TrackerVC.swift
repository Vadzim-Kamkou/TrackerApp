import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Properties
    private var trackerView: UIView?
    private var trackerLabel: UILabel?
    private var trackerTitleLabel: UILabel?
    private var trackerSearchBar: UISearchBar?
    
    private let datePicker = UIDatePicker()

    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        
        cv.register(TrackerCollectionViewCell.self,
                   forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        cv.register(TrackerCategoryHeaderView.self,
                   forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                   withReuseIdentifier: TrackerCategoryHeaderView.identifier)
        
        return cv
    }()
    
    
    
    
    
    private lazy var datePickerButton: UIBarButtonItem = {
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .allEvents)
        
        let button = UIBarButtonItem(customView: datePicker)
        return button
    }()
    
    // MARK: - Data Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<String> = []
    private var currentDate = Date()
    
    private func recordKey(trackerId: UUID, date: Date) -> String {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(trackerId.uuidString)_\(formatter.string(from: dayStart))"
    }
    
    // MARK: - Filtered Data
    private var filteredCategories: [TrackerCategory] {
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                return shouldShowTracker(tracker, for: currentDate)
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }
    }
    
    private func shouldShowTracker(_ tracker: Tracker, for date: Date) -> Bool {
        guard let schedule = tracker.schedule, !schedule.isEmpty else {
            return true
        }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let scheduleWeekday = weekday == 1 ? 7 : weekday - 2
        
        return schedule.contains(scheduleWeekday)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleCategoryAdded(_:)),
                                               name: .categoryAdded,
                                               object: nil)
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
        setupCollectionView()
        updateViewVisibility()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(donePressed))
        view.addGestureRecognizer(tapGesture)
        
        let trackerTitleLabel = UILabel()
        trackerTitleLabel.text = "Трекеры"
        trackerTitleLabel.font = Fonts.ysDisplayBold34 ?? UIFont.systemFont(ofSize: 34)
        trackerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerTitleLabel)
        self.trackerTitleLabel = trackerTitleLabel
        
        let trackerSearchBar = UISearchBar()
        trackerSearchBar.translatesAutoresizingMaskIntoConstraints = false
        trackerSearchBar.searchBarStyle = .minimal
        trackerSearchBar.placeholder = "Поиск"
        view.addSubview(trackerSearchBar)
        self.trackerSearchBar = trackerSearchBar
        
        NSLayoutConstraint.activate([
            trackerTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            trackerSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerSearchBar.topAnchor.constraint(equalTo: trackerTitleLabel.bottomAnchor, constant: 7)
        ])
        
        setupEmptyStateView()
    }
    
    private func setupEmptyStateView() {
        let noTrackerImages = UIImage(resource: .noTrackers)
        let noTrackerImageView = UIImageView(image: noTrackerImages)
        noTrackerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noTrackerImageView)
        
        let trackerLabel = UILabel()
        trackerLabel.text = "Что будем отслеживать?"
        trackerLabel.font = Fonts.ysDisplayMedium12 ?? UIFont.systemFont(ofSize: 12)
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        
        NSLayoutConstraint.activate([
            noTrackerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTrackerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            trackerLabel.centerXAnchor.constraint(equalTo: noTrackerImageView.centerXAnchor),
            trackerLabel.topAnchor.constraint(equalTo: noTrackerImageView.bottomAnchor, constant: 8)
        ])
        
        self.trackerView = noTrackerImageView
        self.trackerLabel = trackerLabel
    }
    
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        view.addSubview(collectionView)
        guard let searchBar = trackerSearchBar else {
            assertionFailure("trackerSearchBar should be initialized before setupCollectionView")
            return
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(148)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(148)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8)
            section.interGroupSpacing = 0
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(34)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        return layout
    }
    
    // MARK: - Helper Methods
    private func updateViewVisibility() {
        let hasTrackers = !filteredCategories.isEmpty
        collectionView.isHidden = !hasTrackers
        trackerView?.isHidden = hasTrackers
        trackerLabel?.isHidden = hasTrackers
    }
    
    private func isTrackerCompletedToday(_ tracker: Tracker) -> Bool {
        let key = recordKey(trackerId: tracker.id, date: currentDate)
        return completedTrackers.contains(key)
    }
    
    private func getCompletedDaysCount(for tracker: Tracker) -> Int {
        return completedTrackers.filter { key in
            key.hasPrefix(tracker.id.uuidString)
        }.count
    }
    
    // MARK: - Date Picker
    @objc private func dateChanged() {
        currentDate = datePicker.date
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.updateViewVisibility()
        }
    }
    
    @objc private func donePressed() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    private func setupNavigationBar() {
        let topNavTrackerPlusButton = UIImage(resource: .topNavTrackerPlusButton)
            .withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: topNavTrackerPlusButton,
            style: .plain,
            target: self,
            action: #selector(openNewScreen)
        )
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    @objc private func openNewScreen() {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.categories = self.categories
        let navigationController = UINavigationController(rootViewController: trackerCreationVC)
        present(navigationController, animated: true)
    }
    
    @objc private func handleCategoryAdded(_ note: Notification) {
        guard let newCategory = note.object as? TrackerCategory else { return }
        
        if let index = categories.firstIndex(where: { $0.title == newCategory.title }) {
            categories[index] = newCategory
        } else {
            categories.append(newCategory)
        }
        
        updateViewVisibility()
        collectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = isTrackerCompletedToday(tracker)
        let completedDays = getCompletedDaysCount(for: tracker)
        
        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays, currentDate: currentDate) { [weak self] completed in
            self?.handleTrackerCompletion(tracker: tracker, completed: completed)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCategoryHeaderView.identifier,
                for: indexPath
              ) as? TrackerCategoryHeaderView else {
            return UICollectionReusableView()
        }
        
        let categoryTitle = filteredCategories[indexPath.section].title
        headerView.configure(with: categoryTitle)
        return headerView
    }
}

// MARK: - UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDelegate {
    private func handleTrackerCompletion(tracker: Tracker, completed: Bool) {
        let key = recordKey(trackerId: tracker.id, date: currentDate)
        
        if completed {
            completedTrackers.insert(key)
        } else {
            completedTrackers.remove(key)
        }
    }
}

extension Notification.Name {
    static let categoryAdded = Notification.Name("categoryAdded")
}
