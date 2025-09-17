import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("Unable to get AppDelegate")
            return
        }
        
        let coreDataManager = appDelegate.coreDataManager
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplashViewController(coreDataManager: coreDataManager)
        window?.makeKeyAndVisible()
    }
}
