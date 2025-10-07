import UIKit

final class TabBarController: UITabBarController {
    
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarSeparator()
        
        let trackerVC = TrackerViewController(coreDataManager: coreDataManager)
        let statisticsVC = StatisticsViewController(coreDataManager: coreDataManager)
        let trackerNav = UINavigationController(rootViewController: trackerVC)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.ysDisplayMedium10 ?? UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        
        trackerVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: "Trackers tab title"),
            image: UIImage(resource: .tapBarTrackerIconPassive),
            selectedImage: UIImage(resource: .tapBarTrackerIconActive)
        )
        trackerVC.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        
        statisticsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics", comment: "Statistics tab title"),
            image: UIImage(resource: .tapBarStatisticsPassive),
            selectedImage: UIImage(resource: .tapBarStatisticsActive)
        )
        statisticsVC.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        
        viewControllers = [trackerNav, statisticsVC]
    }
    
    private func setupTabBarSeparator() {
        let separator = UIView()
        separator.backgroundColor = .appGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        tabBar.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
