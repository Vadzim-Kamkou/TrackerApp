import UIKit

class TrackerViewController: UIViewController {
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
    }
    
    @objc private func openNewScreen() {
        print("topnav")
//        let destinationVC = NewScreenViewController() // создайте свой класс
//        navigationController?.pushViewController(destinationVC, animated: true)
    }
}

