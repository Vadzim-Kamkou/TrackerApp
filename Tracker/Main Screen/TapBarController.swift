import UIKit

final class TabBarController: UITabBarController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackerVC = TrackerViewController()
        let statisticsVC = StatisticsViewController()
        let trackerNav = UINavigationController(rootViewController: trackerVC)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "YSDisplay-Medium", size: 10) ?? UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
    
        trackerVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tapBarTrackerIconPassive),
            selectedImage: UIImage(resource: .tapBarTrackerIconActive)
        )
        trackerVC.tabBarItem.setTitleTextAttributes(attributes, for: .normal)

        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tapBarStatisticsPassive),
            selectedImage: UIImage(resource: .tapBarStatisticsActive)
        )
        statisticsVC.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        
       self.viewControllers = [trackerNav, statisticsVC]
    }
}
