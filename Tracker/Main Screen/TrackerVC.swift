import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Properties
    private let coreDataManager: CoreDataManagerProtocol
    
    
    private lazy var trackerStore: TrackerStore? = {
        do {
            return try TrackerStore(context: coreDataManager.viewContext)
        } catch {
            print("Failed to initialize TrackerStore: \(error)")
            return nil
        }
    }()
    private lazy var trackerCategoryStore: TrackerCategoryStore? = {
        do {
            return try TrackerCategoryStore(context: coreDataManager.viewContext)
        } catch {
            print("Failed to initialize TrackerStore: \(error)")
            return nil
        }
    }()
    private lazy var trackerRecordStore: TrackerRecordStore? = {
        do {
            return try TrackerRecordStore(context: coreDataManager.viewContext)
        } catch {
            print("Failed to initialize TrackerRecordStore: \(error)")
            return nil
        }
    }()
    
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
    
    // MARK: - Properties Data
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
    
    private var filteredCategories: [TrackerCategory] {
        let result: [TrackerCategory] = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let shouldShow = shouldShowTracker(tracker, for: currentDate)
                return shouldShow
            }
            
            if filteredTrackers.isEmpty {
                return nil
            } else {
                return TrackerCategory(
                    title: category.title,
                    trackers: filteredTrackers
                )
            }
        }
        return result
    }
    
    // MARK: - Init
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
        setupCollectionView()
        updateViewVisibility()
        
        trackerStore?.delegate = self
        trackerCategoryStore?.delegate = self
        trackerRecordStore?.delegate = self
        
        loadInitialData()
    }

    // MARK: - Setup
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(donePressed))
        view.addGestureRecognizer(tapGesture)
        
        let trackerTitleLabel = UILabel()
        trackerTitleLabel.text = NSLocalizedString("trackers", comment: "Main trackers title")
        trackerTitleLabel.font = Fonts.ysDisplayBold34 ?? UIFont.systemFont(ofSize: 34)
        trackerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerTitleLabel)
        self.trackerTitleLabel = trackerTitleLabel
        
        let trackerSearchBar = UISearchBar()
        trackerSearchBar.translatesAutoresizingMaskIntoConstraints = false
        trackerSearchBar.searchBarStyle = .minimal
        trackerSearchBar.placeholder = NSLocalizedString("search", comment: "Search placeholder")
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
    
    private func loadInitialData() {
        print("Loading initial data from Core Data")
        loadTrackersCategoryFromStore()
        loadTrackerRecordsFromStore()
        updateViewVisibility()
    }
    
    private func setupEmptyStateView() {
        let noTrackerImages = UIImage(resource: .noTrackers)
        let noTrackerImageView = UIImageView(image: noTrackerImages)
        noTrackerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noTrackerImageView)
        
        let trackerLabel = UILabel()
        trackerLabel.text = NSLocalizedString("what_to_track", comment: "Empty state message")
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
    
    private func shouldShowTracker(_ tracker: Tracker, for date: Date) -> Bool {
        guard let schedule = tracker.schedule, !schedule.isEmpty else {
            return true
        }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Преобразуем Calendar weekday к нашей системе
        let scheduleWeekday: Int
        if weekday == 1 {
            scheduleWeekday = 6  // Воскресенье = 6
        } else {
            scheduleWeekday = weekday - 2  // Понедельник = 0, и т.д.
        }
        
        let shouldShow = schedule.contains(scheduleWeekday)
        return shouldShow
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
        let newDate = datePicker.date
        
        guard newDate != currentDate else { return }
        
        currentDate = newDate
        
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
        let trackerCreationVC = TrackerCreationViewController(
            coreDataManager: coreDataManager,
            trackerStore: trackerStore,
            trackerCategoryStore: trackerCategoryStore
        )
        
        let navigationController = UINavigationController(rootViewController: trackerCreationVC)
        present(navigationController, animated: true)
    }
}

// MARK: - Extension UICollectionViewDataSource
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

// MARK: - Extension UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDelegate {
    private func handleTrackerCompletion(tracker: Tracker, completed: Bool) {
        let key = recordKey(trackerId: tracker.id, date: currentDate)
        
        guard let trackerRecordStore = trackerRecordStore else {
            print("TrackerRecordStore is not available")
            return
        }
        
        do {
            if completed {
                let record = TrackerRecord(id: tracker.id, date: currentDate)
                trackerRecordStore.addTrackerRecord(record)
                completedTrackers.insert(key)
            } else {
                try trackerRecordStore.deleteTrackerRecord(with: tracker.id, on: currentDate)
                completedTrackers.remove(key)
            }
        } catch {
            print("Failed to save tracker completion: \(error)")
        }
    }
}

// MARK: - Extension
extension TrackerViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        print("TrackerStore updated")
        
        DispatchQueue.main.async { [weak self] in
            self?.loadTrackersCategoryFromStore()
            self?.loadTrackerRecordsFromStore()
            self?.collectionView.reloadData()
            self?.updateViewVisibility()
        }
    }
}
// MARK: - Extension
extension TrackerViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        print("TrackerCategoryStore updated")
        
        DispatchQueue.main.async { [weak self] in
            self?.loadTrackersCategoryFromStore()
            self?.collectionView.reloadData()
            self?.updateViewVisibility()
        }
    }
    
    private func loadTrackersCategoryFromStore() {
        guard let trackerCategoryStore = trackerCategoryStore else {
            print("TrackerCategoryStore is not available")
            return
        }
        
        do {
            let trackersCategory = try trackerCategoryStore.fetchTrackerCategory()
            
            self.categories = trackersCategory
            
            
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
                self?.updateViewVisibility()
            }
            
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
}
// MARK: - Extension
extension TrackerViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        print("TrackerRecordStore updated")
        
        DispatchQueue.main.async { [weak self] in
            self?.loadTrackerRecordsFromStore()
        }
    }
    
    private func loadTrackerRecordsFromStore() {
        guard let trackerRecordStore = trackerRecordStore else {
            print("TrackerRecordStore is not available")
            return
        }
        
        do {
            let records = try trackerRecordStore.fetchTrackerRecord()
            
            completedTrackers = Set(records.map { record in
                recordKey(trackerId: record.id, date: record.date)
            })
            
        } catch {
            print("Failed to fetch tracker records: \(error)")
        }
    }
}
