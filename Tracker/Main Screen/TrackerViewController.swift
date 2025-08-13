import UIKit

class TrackerViewController: UIViewController {
    
    // MARK: Property
    private var trackerView: UIView?
    private var trackerLabel: UILabel?
    private var trackerTitleLabel: UILabel?
    private var trackerSearchBar: UISearchBar?
    
    //private let dateTextField = NoCursorTextField()
    private let datePicker = UIDatePicker()
    
    
    private lazy var datePickerButton: UIBarButtonItem = {
        let button = UIBarButtonItem(customView: datePicker)
        return button
    }()
    
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleCategoryAdded(_:)),
                                               name: .categoryAdded,
                                               object: nil)
        view.backgroundColor = .white
        setupDatePicker()
        setupNavigationBar()
                
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(donePressed))
        view.addGestureRecognizer(tapGesture)
        
        let trackerTitleLabel = UILabel()
        trackerTitleLabel.text = "Трекеры"
        trackerTitleLabel.font = UIFont(name: "YSDisplay-Bold", size: 34) ?? UIFont.systemFont(ofSize: 34)
        trackerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerTitleLabel)
        NSLayoutConstraint.activate([
            trackerTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            trackerTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
        self.trackerTitleLabel = trackerTitleLabel
        
        let trackerSearchBar = UISearchBar()
        trackerSearchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerSearchBar)
        trackerSearchBar.searchBarStyle = .minimal
        NSLayoutConstraint.activate([
            trackerSearchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerSearchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerSearchBar.topAnchor.constraint(equalTo: trackerTitleLabel.bottomAnchor, constant: 0)
        ])
        self.trackerSearchBar = trackerSearchBar
        
        // создание картинки, если трекеров нет
        let noTrackerImages = UIImage(resource: .noTrackers)
        let noTrackerImageView = UIImageView(image: noTrackerImages)
        noTrackerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noTrackerImageView)
        NSLayoutConstraint.activate([
            noTrackerImageView.centerXAnchor.constraint(equalTo: super.view.centerXAnchor),
            noTrackerImageView.centerYAnchor.constraint(equalTo: super.view.centerYAnchor)
        ])
        self.trackerView = noTrackerImageView
        
        let trackerLabel = UILabel()
        trackerLabel.text = "Что будем отслеживать?"
        trackerLabel.font = UIFont(name: "YSDisplay-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        NSLayoutConstraint.activate([
            trackerLabel.centerXAnchor.constraint(equalTo: noTrackerImageView.centerXAnchor),
            trackerLabel.topAnchor.constraint(equalTo: noTrackerImageView.bottomAnchor, constant: 10)
        ])
        self.trackerLabel = trackerLabel
    }
    
//    private func setupDateTextField() {
//        dateTextField.backgroundColor = .appDatePicker
//        dateTextField.layer.cornerRadius = 8
//        dateTextField.textAlignment = .center
//        dateTextField.font = UIFont(name: "YSDisplay-Medium", size: 17) ?? UIFont.systemFont(ofSize: 17)
//        dateTextField.textColor = .appBlack
//        view.addSubview(dateTextField)
//        
//        dateTextField.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            dateTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -100),
//            dateTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            dateTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            dateTextField.widthAnchor.constraint(equalToConstant: 77),
//            dateTextField.heightAnchor.constraint(equalToConstant: 34)
//        ])
//        
//        datePicker.datePickerMode = .date
//        datePicker.locale = Locale(identifier: "ru_RU")
//        datePicker.preferredDatePickerStyle = .compact
//        datePicker.date = Date()
//        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
//        dateTextField.inputView = datePicker
//        
//        
//        dateChanged()
//        
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        let done = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(donePressed))
//        toolbar.setItems([done], animated: true)
//        dateTextField.inputAccessoryView = toolbar
//    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
    }
    
    @objc private func dateChanged() {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd.MM.yy"
//        dateTextField.text = formatter.string(from: datePicker.date)
    }
    
    @objc private func donePressed() {
        view.endEditing(true)
        //dateTextField.resignFirstResponder()
    }
    
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
        
        //Когда пользователь нажимает на + в ячейке трекера, добавляется соответствующая запись в completedTrackers.
        //Если пользователь убирает пометку о выполненности в ячейке трекера, элемент удаляется из массива.
    }
    
    @objc private func handleCategoryAdded(_ note: Notification) {
            guard let newCategory = note.object as? TrackerCategory else { return }
            categories.append(newCategory)
        }
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
}

//class NoCursorTextField: UITextField {
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        return .zero
//    }
//}

extension Notification.Name {
    static let categoryAdded = Notification.Name("categoryAdded")
}


