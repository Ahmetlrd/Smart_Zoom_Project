import Cocoa
import FlutterMacOS
/*
 @main
 class AppDelegate: FlutterAppDelegate {
 override func applicationDidFinishLaunching(_ notification: Notification) {
 print("🔥 AppDelegate launched")
 
 if let flutterWindow = mainFlutterWindow,
 let controller = flutterWindow.contentViewController as? FlutterViewController {
 print("if içerisine girildi")
 let channel = FlutterMethodChannel(
 name: "deep_link_channel",
 binaryMessenger: controller.engine.binaryMessenger
 )
 
 NotificationCenter.default.addObserver(
 forName: Notification.Name("IncomingLink"),
 object: nil,
 queue: nil
 ) { notification in
 if let url = notification.object as? URL {
 print("📩 Notified with URL: \(url)")
 channel.invokeMethod("incomingLink", arguments: url.absoluteString)
 }
 }
 }
 
 super.applicationDidFinishLaunching(notification)
 }
 
 override func application(_ application: NSApplication, open urls: [URL]) {
 if let url = urls.first {
 print("📬 Received deep link: \(url)")
 NotificationCenter.default.post(
 name: Notification.Name("IncomingLink"),
 object: url
 )
 }
 }
 
 override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
 return true
 }
 }
 */

import app_links
@main
class AppDelegate: FlutterAppDelegate {
    
    public override func application(_ application: NSApplication,
                                     continue userActivity: NSUserActivity,
                                     restorationHandler: @escaping ([any NSUserActivityRestoring]) -> Void) -> Bool {
        print("girildi")
        guard let url = AppLinks.shared.getUniversalLink(userActivity) else {
            return false
        }
        print("url: \(url)")
        AppLinks.shared.handleLink(link: url.absoluteString)
        
        return true // Returning true will stop the propagation to other packages
    }
    
    override func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            print("url: \(url)")
            AppLinks.shared.handleLink(link: url.absoluteString)

        }
    }
    
}
