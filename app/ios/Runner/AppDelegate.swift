import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Bundle.main.infoDictionary?["GMSApiKey"] as? String {
        GMSServices.provideAPIKey(apiKey)
    } else {
        print("No se pudo encontrar la API key en Info.plist")
    }
    //GMSServices.provideAPIKey("${GOOGLE_MAPS_API_KEY}")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
