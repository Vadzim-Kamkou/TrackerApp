import UIKit

final class SplashViewController: UIViewController {

    // MARK: Property
    private var logoSplashScreen: UIView?

    
    // MARK: Life cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let window = view.window else {
            assertionFailure("Invalid Configuration - view.window is nil")
            return
        }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSplashView()
    }

    // MARK: Private functions
    private func configSplashView() {
        print("SplashView")
        
        view.backgroundColor = UIColor.appBlue
        
        let logoImage = UIImage(resource: .splashLogo)
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        logoImageView.centerXAnchor.constraint(equalTo: super.view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: super.view.centerYAnchor).isActive = true
        self.logoSplashScreen = logoImageView
    }
}

