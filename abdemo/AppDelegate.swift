import Foundation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    setupServices(application)
    setupWindow()

    application.applicationIconBadgeNumber = ABTestingService.shared.getIntValue(forKey: .badgeCount) ?? .zero

    return true
  }
}

private extension AppDelegate {
  func setupWindow() {
    let viewController = MainView.build()
    let navigationController = UINavigationController(rootViewController: viewController)

    let window = UIWindow()
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
    self.window = window
  }

  func setupServices(_ application: UIApplication) {
    ABTestingService.shared.configure()

    UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { _, _ in }
    application.registerForRemoteNotifications()
  }
}
