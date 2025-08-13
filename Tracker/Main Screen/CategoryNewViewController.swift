//
//  CategoryNewViewController.swift
//  Tracker
//
//  Created by Vadzim on 25.07.25.
//
import UIKit

protocol CategoryNewViewControllerDelegate: AnyObject {
    func didCreateCategory(_ category: TrackerCategory)
}

class CategoryNewViewController: UIViewController {
    
    weak var delegate: CategoryNewViewControllerDelegate?
    
    
    private lazy var categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = UIFont(name: "YSDisplay-Medium", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .medium)
        textField.textColor = .appBlack
        textField.backgroundColor = .appBackgroundDay
        textField.layer.cornerRadius = 16
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        textField.delegate = self
        textField.returnKeyType = .done
        
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .appGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTapGesture()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(categoryTextField)
        view.addSubview(doneButton)
        
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            categoryTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTextField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
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
        title = "Новая категория"
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        let isEmpty = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        doneButton.isEnabled = !isEmpty
        
        if isEmpty {
            doneButton.backgroundColor = .appGray
        } else {
            doneButton.backgroundColor = .appBlack
        }
    }
    
    @objc private func doneButtonTapped() {
        guard let categoryName = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !categoryName.isEmpty else {
            return
        }
        
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        NotificationCenter.default.post(name: .categoryAdded, object: newCategory)
        delegate?.didCreateCategory(newCategory)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CategoryNewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
