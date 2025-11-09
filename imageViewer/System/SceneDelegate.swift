import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var serviceHolder: ServiceHolder?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let serviceHolder = ServiceHolder()
        self.serviceHolder = serviceHolder
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        let viewController = ImageSelectViewController.assemble(imageService: serviceHolder.ImageService)
        navigationController.viewControllers = [viewController]
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

}

