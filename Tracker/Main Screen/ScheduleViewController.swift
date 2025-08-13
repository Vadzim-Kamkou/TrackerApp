import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: Set<Int>, daysString: String)
}
class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private lazy var scheduleWeekdaysListView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appBackgroundDay
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .appBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let weekdays = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private let weekdayShortNames = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    private var selectedDays: Set<Int> = []
    private var weekdayViews: [UIView] = []
    private var separatorViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        createWeekdayItems()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scheduleWeekdaysListView)
        view.addSubview(saveButton)
        
        scheduleWeekdaysListView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scheduleWeekdaysListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scheduleWeekdaysListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scheduleWeekdaysListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: UIFont(name: "YSDisplay-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(resource: .appBlack)
        ]
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        title = "Расписание"
    }
    
    private func createWeekdayItems() {
        var previousView: UIView?
        
        for (index, weekday) in weekdays.enumerated() {
            let weekdayView = UIView()
            weekdayView.backgroundColor = .clear
            weekdayView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = weekday
            label.font = UIFont(name: "YSDisplay-Medium", size: 17) ?? UIFont.systemFont(ofSize: 17)
            label.textColor = .appBlack
            label.translatesAutoresizingMaskIntoConstraints = false
            weekdayView.addSubview(label)
            
            let toggle = UISwitch()
            toggle.isOn = selectedDays.contains(index)
            toggle.tag = index
            toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
            toggle.translatesAutoresizingMaskIntoConstraints = false
            weekdayView.addSubview(toggle)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: weekdayView.leadingAnchor, constant: 16),
                label.centerYAnchor.constraint(equalTo: weekdayView.centerYAnchor),
                
                toggle.trailingAnchor.constraint(equalTo: weekdayView.trailingAnchor, constant: -16),
                toggle.centerYAnchor.constraint(equalTo: weekdayView.centerYAnchor)
            ])
            
            scheduleWeekdaysListView.addSubview(weekdayView)
            weekdayViews.append(weekdayView)
            
            if let previous = previousView {
                NSLayoutConstraint.activate([
                    weekdayView.topAnchor.constraint(equalTo: previous.bottomAnchor),
                    weekdayView.leadingAnchor.constraint(equalTo: scheduleWeekdaysListView.leadingAnchor),
                    weekdayView.trailingAnchor.constraint(equalTo: scheduleWeekdaysListView.trailingAnchor),
                    weekdayView.heightAnchor.constraint(equalToConstant: 75)
                ])
            } else {
                NSLayoutConstraint.activate([
                    weekdayView.topAnchor.constraint(equalTo: scheduleWeekdaysListView.topAnchor),
                    weekdayView.leadingAnchor.constraint(equalTo: scheduleWeekdaysListView.leadingAnchor),
                    weekdayView.trailingAnchor.constraint(equalTo: scheduleWeekdaysListView.trailingAnchor),
                    weekdayView.heightAnchor.constraint(equalToConstant: 75)
                ])
            }
            
            if index < weekdays.count - 1 {
                let separatorView = UIView()
                separatorView.backgroundColor = UIColor.systemGray4
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                scheduleWeekdaysListView.addSubview(separatorView)
                separatorViews.append(separatorView)
                
                NSLayoutConstraint.activate([
                    separatorView.leadingAnchor.constraint(equalTo: scheduleWeekdaysListView.leadingAnchor, constant: 16),
                    separatorView.trailingAnchor.constraint(equalTo: scheduleWeekdaysListView.trailingAnchor, constant: -16),
                    separatorView.topAnchor.constraint(equalTo: weekdayView.bottomAnchor),
                    separatorView.heightAnchor.constraint(equalToConstant: 0.5)
                ])
            }
            
            previousView = weekdayView
        }
        
        if let lastView = previousView {
            lastView.bottomAnchor.constraint(equalTo: scheduleWeekdaysListView.bottomAnchor).isActive = true
        }
    }
    
    private func getSelectedDaysString() -> String {
        let sortedDays = selectedDays.sorted()
        let selectedDayNames = sortedDays.map { weekdayShortNames[$0] }
        
        if selectedDayNames.isEmpty {
            return ""
        } else if selectedDayNames.count == 7 {
            return "Каждый день"
        } else {
            return selectedDayNames.joined(separator: ", ")
        }
    }
    
    @objc private func toggleChanged(_ sender: UISwitch) {
        if sender.isOn {
            selectedDays.insert(sender.tag)
        } else {
            selectedDays.remove(sender.tag)
        }
    }
    
    @objc private func saveButtonTapped() {
        let selectedString = getSelectedDaysString()
        delegate?.didSelectDays(selectedDays, daysString: selectedString)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = weekdays[indexPath.row]
        cell.textLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        // Добавляем toggle
        let toggle = UISwitch()
        toggle.isOn = selectedDays.contains(indexPath.row)
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        toggle.tag = indexPath.row
        cell.accessoryView = toggle
        
        return cell
    }
}
