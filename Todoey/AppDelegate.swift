import UIKit
import CoreData
import RealmSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        let config = Realm.Configuration(schemaVersion: 5)
        Realm.Configuration.defaultConfiguration = config
        return true
    }
}
