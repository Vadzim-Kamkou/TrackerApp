//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Vadzim on 23.07.25.
//

import UIKit


class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    var categories: [TrackerCategory] = []
    private var selectedIndex: Int?
    var preselectedTitle: String?
    
    // таблица-контейнер для UIView категорий со скроллом
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle   = .none
        tv.dataSource = self
        tv.delegate   = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // UIView для состояния, когда нет категорий
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(resource: .noTrackers))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont(name: "YSDisplay-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
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
    
    // кнопка создания категорий
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .appBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return button
    }()
    
    // загружаем экран
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        
        if let title = preselectedTitle {
            selectedIndex = categories.firstIndex { $0.title == title }
        }
        
        updateUI()
    }
    
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
            .font: UIFont(name: "YSDisplay-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(resource: .appBlack)
        ]
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        title = "Категория"
    }
    
    private func updateUI() {
        if categories.isEmpty {
            emptyStateView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    // кнопка создания новой категории
    @objc private func addCategoryTapped() {
        let categoryNewVC = CategoryNewViewController()
        categoryNewVC.delegate = self
        let navigationController = UINavigationController(rootViewController: categoryNewVC)
        present(navigationController, animated: true)
        
    }
    
    // если категория была нажата - закрываем экран и передаем выбранную категорию.
    @objc private func categoryRowTapped(_ gr: UITapGestureRecognizer) {
        guard let row = gr.view else { return }
        selectedIndex = row.tag
        tableView.reloadData()
        let chosen = categories[row.tag]
        delegate?.didSelectCategory(chosen)
        dismiss(animated: true)
    }
    
}

// MARK: - CategoryNewViewControllerDelegate
extension CategoryViewController: CategoryNewViewControllerDelegate {
    
    func didCreateCategory(_ category: TrackerCategory) {
        categories.append(category)
        selectedIndex = categories.count - 1
        updateUI()
        tableView.reloadData()

        delegate?.didSelectCategory(category)

        dismiss(animated: true)
  
    }
}


// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear

        let listView = UIView()
        listView.backgroundColor = .appBackgroundDay
        listView.layer.cornerRadius = 16
        listView.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(listView)

        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            listView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])

        addCategorySubviews(into: listView)
        return cell
    }

    private func addCategorySubviews(into parent: UIView) {
        parent.subviews.forEach { $0.removeFromSuperview() }
        var previous: UIView?
        for (idx, category) in categories.enumerated() {
            let row = makeCategoryRow(title: category.title, index: idx)
            parent.addSubview(row)
            
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
                row.heightAnchor.constraint(equalToConstant: 75)
            ])
            
            if let prev = previous {
                row.topAnchor.constraint(equalTo: prev.bottomAnchor).isActive = true
            } else {
                row.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
            }
            
            // cепаратор
            if idx < categories.count - 1 {
                let sep = UIView()
                sep.backgroundColor = .systemGray4
                sep.translatesAutoresizingMaskIntoConstraints = false
                parent.addSubview(sep)
                
                NSLayoutConstraint.activate([
                    sep.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 16),
                    sep.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -16),
                    sep.topAnchor.constraint(equalTo: row.bottomAnchor),
                    sep.heightAnchor.constraint(equalToConstant: 0.5)
                ])
                
                previous = sep
            } else {
                previous = row
            }
        }
        previous?.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }

    private func makeCategoryRow(title: String, index: Int) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "YSDisplay-Medium", size: 16) ?? .systemFont(ofSize: 16)
        label.textColor = .appBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        let icon  = UIImageView(image: UIImage(resource: .check))
        icon.isHidden = selectedIndex != index
        icon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.addSubview(icon)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            icon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        view.tag = index
        let tap = UITapGestureRecognizer(target: self, action: #selector(categoryRowTapped(_:)))
        view.addGestureRecognizer(tap)
        
        return view
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
