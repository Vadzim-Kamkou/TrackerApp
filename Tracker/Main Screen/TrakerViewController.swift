import UIKit

class TrackerViewController: UIViewController {
    
    // MARK: Property
    private var trackerView: UIView?
    private var trackerLabel: UILabel?
    private var trackerTitleLabel: UILabel?
    private var trackerSearchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        let topNavTrackerPlusButton = UIImage(resource: .topNavTrackerPlusButton)
                        .withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: topNavTrackerPlusButton,
            style: .plain,
            target: self,
            action: #selector(openNewScreen)
        )
        
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
            noTrackerImageView.centerXAnchor.constraint(equalTo: super.view.centerXAnchor)
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
    
    @objc private func openNewScreen() {
        print("topnav")
//        let destinationVC = NewScreenViewController() // создайте свой класс
//        navigationController?.pushViewController(destinationVC, animated: true)
    }
}

