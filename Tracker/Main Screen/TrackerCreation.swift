import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

final class TrackerCreationViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    private var chosenCategoryTitle: String?
    private var categorySubtitleLabel: UILabel?
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    private let trackerCreateTextViewMaxCharacters = 38
    private var isOverLimitTextView = false
    private let trackerCreateTextViewDefaultText = "Введите название трекера"
    
    private lazy var trackerCreateTextView: UITextView = {
        let textView = UITextView()
        textView.text = trackerCreateTextViewDefaultText
        
        textView.textAlignment = .left
        
        textView.font = Fonts.ysDisplayMedium17 ?? UIFont.systemFont(ofSize: 17, weight: .medium)
        textView.textColor = .appGray
        textView.backgroundColor = .appBackgroundDay
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 28, left: 12, bottom: 4, right: 40)
        textView.textContainer.maximumNumberOfLines = 2
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.isEditable = true
        textView.delegate = self
        
        return textView
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .appGray
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var trackerSettingsListView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appBackgroundDay
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var trackerSettingsCategory: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let firstItemView = UIView()
        firstItemView.backgroundColor = .clear
        firstItemView.translatesAutoresizingMaskIntoConstraints = false
        
        let firstTitleLabel = UILabel()
        firstTitleLabel.text = "Категория"
        firstTitleLabel.font = Fonts.ysDisplayMedium17 ?? UIFont.systemFont(ofSize: 17)
        firstTitleLabel.textColor = .appBlack
        
        var firstSubtitleLabel = UILabel()
        self.categorySubtitleLabel = firstSubtitleLabel
        
        firstSubtitleLabel.font = Fonts.ysDisplayMedium17 ?? UIFont.systemFont(ofSize: 17)
        firstSubtitleLabel.textColor = .appGray
        
        let arrowImageView = UIImageView(image: UIImage(resource: .chevronRight))
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        firstItemView.addSubview(firstTitleLabel)
        firstItemView.addSubview(firstSubtitleLabel)
        firstItemView.addSubview(arrowImageView)
        firstTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        firstSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstTitleLabel.leadingAnchor.constraint(equalTo: firstItemView.leadingAnchor, constant: 16),
            firstTitleLabel.topAnchor.constraint(equalTo: firstItemView.topAnchor, constant: 12),
            
            firstSubtitleLabel.leadingAnchor.constraint(equalTo: firstItemView.leadingAnchor, constant: 16),
            firstSubtitleLabel.topAnchor.constraint(equalTo: firstTitleLabel.bottomAnchor, constant: 2),
            firstSubtitleLabel.bottomAnchor.constraint(equalTo: firstItemView.bottomAnchor, constant: -12),
            
            arrowImageView.centerYAnchor.constraint(equalTo: firstItemView.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: firstItemView.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
            arrowImageView.heightAnchor.constraint(equalToConstant: 24)
            
        ])
        
        view.addSubview(firstItemView)
        
        NSLayoutConstraint.activate([
            firstItemView.topAnchor.constraint(equalTo: view.topAnchor),
            firstItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            firstItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            firstItemView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private var selectedDaysString: String = ""
    private var selectedDays: Set<Int> = []
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var trackerCreationCancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.titleLabel?.font = Fonts.ysDisplayMedium16 ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.setTitleColor(.appRed, for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(resource: .appRed).cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(trackerCreationCancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackerCreationCreateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = Fonts.ysDisplayMedium16 ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .appGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(trackerCreationCreateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scheduleViewController: ScheduleViewController = {
        let vc = ScheduleViewController()
        vc.delegate = self
        return vc
    }()
    
    private let trackerColors: [UIColor] = [
        .systemRed,
        .systemOrange,
        .systemYellow,
        .systemGreen,
        .systemBlue,
        .systemPurple,
        .systemPink,
        .systemTeal,
        .systemIndigo,
        .systemBrown
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.isUserInteractionEnabled = true
        trackerCreateTextView.isUserInteractionEnabled = true
        
        buttonStackView.isUserInteractionEnabled = true
        trackerCreationCancelButton.isUserInteractionEnabled = true
        trackerCreationCreateButton.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackerCreateTextView.delegate = self
    }
    
    private func setupNavigationBar() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: Fonts.ysDisplayMedium16 ?? UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor(resource: .appBlack)
        ]
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        title = "Новая привычка"
    }
    
    private func createTrackerSettingsSchedule() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Расписание"
        label.font = Fonts.ysDisplayMedium17 ?? UIFont.systemFont(ofSize: 17)
        label.textColor = .appBlack
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let daysLabel = UILabel()
        daysLabel.text = selectedDaysString
        daysLabel.font = Fonts.ysDisplayMedium17 ?? UIFont.systemFont(ofSize: 17)
        daysLabel.textColor = .appGray
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(daysLabel)
        
        let arrowImageView = UIImageView(image: UIImage(resource: .chevronRight))
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arrowImageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            
            daysLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daysLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2),
            daysLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            
            arrowImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
            arrowImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return view
    }

    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(trackerCreationCancelButton)
        buttonStackView.addArrangedSubview(trackerCreationCreateButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -20),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        setupTrackerCreationCreateButtonUI()
    }
    
    private func setupTrackerCreationCreateButtonUI () {
        if trackerCreateTextView.text == trackerCreateTextViewDefaultText ||
            chosenCategoryTitle == nil ||
            selectedDaysString.isEmpty
        {
            trackerCreationCreateButton.backgroundColor = .appGray
        } else {
            trackerCreationCreateButton.backgroundColor = .appBlack
        }
    }
    
    private func updateScheduleDisplay(_ daysString: String) {
        selectedDaysString = daysString
        tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }
    
    private func getRandomColor() -> UIColor {
        trackerColors.randomElement() ?? .systemBlue
    }
    
    @objc private func trackerCreationCancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func trackerCreationCreateButtonTapped() {
        guard let trackerName = trackerCreateTextView.text,
              trackerName != trackerCreateTextViewDefaultText,
              !trackerName.isEmpty,
              let categoryTitle = chosenCategoryTitle,
              !selectedDaysString.isEmpty else {
            return
        }
        
        let newTracker = Tracker(
            name: trackerName,
            color: getRandomColor(),
            emoji: "😊",
            schedule: Array(selectedDays)
        )
        
        let newCategories = categories.map { category in
            if category.title == categoryTitle {
                let newTrackers = category.trackers + [newTracker]
                return TrackerCategory(title: categoryTitle, trackers: newTrackers)
            } else {
                return category
            }
        }
        
        categories = newCategories
        
        if let updatedCategory = newCategories.first(where: { $0.title == categoryTitle }) {
            NotificationCenter.default.post(name: .categoryAdded, object: updatedCategory)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func clearButtonTapped() {
        trackerCreateTextView.text = ""
        clearButton.isHidden = true
        self.textViewDidChange(trackerCreateTextView)
    }
    
    @objc private func dismissKeyboard() {
        trackerCreateTextView.resignFirstResponder()
    }
    
    @objc private func scheduleTapped() {
        let navigationController = UINavigationController(rootViewController: scheduleViewController)
        present(navigationController, animated: true)
    }
    @objc private func categoryTapped() {
        let categoryVC = CategoryViewController()
        categoryVC.delegate = self
        categoryVC.categories       = self.categories
        categoryVC.preselectedTitle = chosenCategoryTitle
        let navigationController = UINavigationController(rootViewController: categoryVC)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TrackerCreationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            cell.contentView.addSubview(trackerCreateTextView)
            cell.contentView.addSubview(clearButton)
            
            trackerCreateTextView.translatesAutoresizingMaskIntoConstraints = false
            clearButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                trackerCreateTextView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                trackerCreateTextView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                trackerCreateTextView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                trackerCreateTextView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                trackerCreateTextView.heightAnchor.constraint(equalToConstant: 75),
                
                clearButton.centerYAnchor.constraint(equalTo: trackerCreateTextView.centerYAnchor),
                clearButton.trailingAnchor.constraint(equalTo: trackerCreateTextView.trailingAnchor, constant: -12),
                clearButton.widthAnchor.constraint(equalToConstant: 24),
                clearButton.heightAnchor.constraint(equalToConstant: 24)
            ])
            
        case 1 : break
            
        case 2:
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            trackerSettingsListView.subviews.forEach { $0.removeFromSuperview() }
            
            
            cell.contentView.addSubview(trackerSettingsListView)
            trackerSettingsListView.addSubview(trackerSettingsCategory)
            
            let scheduleView = createTrackerSettingsSchedule()
            trackerSettingsListView.addSubview(scheduleView)
            trackerSettingsListView.addSubview(separatorView)
            
            NSLayoutConstraint.activate([
                trackerSettingsListView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                trackerSettingsListView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                trackerSettingsListView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                trackerSettingsListView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                
                trackerSettingsCategory.topAnchor.constraint(equalTo: trackerSettingsListView.topAnchor),
                trackerSettingsCategory.leadingAnchor.constraint(equalTo: trackerSettingsListView.leadingAnchor),
                trackerSettingsCategory.trailingAnchor.constraint(equalTo: trackerSettingsListView.trailingAnchor),
                trackerSettingsCategory.heightAnchor.constraint(equalToConstant: 75),
                
                scheduleView.topAnchor.constraint(equalTo: trackerSettingsCategory.bottomAnchor),
                scheduleView.leadingAnchor.constraint(equalTo: trackerSettingsListView.leadingAnchor),
                scheduleView.trailingAnchor.constraint(equalTo: trackerSettingsListView.trailingAnchor),
                scheduleView.bottomAnchor.constraint(equalTo: trackerSettingsListView.bottomAnchor),
                scheduleView.heightAnchor.constraint(equalToConstant: 75),
                
                separatorView.leadingAnchor.constraint(equalTo: trackerSettingsListView.leadingAnchor, constant: 16),
                separatorView.trailingAnchor.constraint(equalTo: trackerSettingsListView.trailingAnchor, constant: -16),
                separatorView.topAnchor.constraint(equalTo: trackerSettingsCategory.bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 0.5)
            ])
            
        default:
            break
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrackerCreationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        case 1:
            return 20
        case 2:
            return 150
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return 0.01
        case 1:
            return 0.01
        case 2:
            return 0.01
        default:
            return 0.01
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && isOverLimitTextView {
            let footerView = UIView()
            footerView.backgroundColor = .clear
            
            let label = UILabel()
            label.text = "Ограничение 38 символов"
            label.font = Fonts.ysDisplayMedium17 ?? UIFont.systemFont(ofSize: 17, weight: .regular)
            label.textColor = UIColor(resource: .appRed)
            label.textAlignment = .center
            
            footerView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
                label.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -4)
            ])
            return footerView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == 0 && isOverLimitTextView ? 30 : 0.01
    }
}

extension TrackerCreationViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if textView.text == trackerCreateTextViewDefaultText {
            textView.text = ""
            textView.textColor = .appBlack
        } else {
            clearButton.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentCount = textView.text?.count ?? 0
        
        let wasOverLimit = isOverLimitTextView
        isOverLimitTextView = currentCount > trackerCreateTextViewMaxCharacters
        
        if currentCount >= trackerCreateTextViewMaxCharacters,
           let text = textView.text,
           let index = text.index(text.startIndex, offsetBy: trackerCreateTextViewMaxCharacters, limitedBy: text.endIndex) {
            textView.text = String(text[..<index])
        }
        
        clearButton.isHidden = textView.text.isEmpty
        textView.textColor = .appBlack
        
        if wasOverLimit != isOverLimitTextView {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = trackerCreateTextViewDefaultText
            textView.textColor = .appGray
        } else {
            clearButton.isHidden = true
        }
        setupTrackerCreationCreateButtonUI()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension TrackerCreationViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: Set<Int>, daysString: String) {
        selectedDays = days
        updateScheduleDisplay(daysString)
        setupTrackerCreationCreateButtonUI()
    }
}

// MARK: - CategoryViewControllerDelegate
extension TrackerCreationViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        chosenCategoryTitle  = category.title
        categorySubtitleLabel?.text = category.title
        if !categories.contains(where: { $0.title == category.title }) {
            categories.append(category)
        }
        dismiss(animated: true)
        setupTrackerCreationCreateButtonUI()
    }
}
