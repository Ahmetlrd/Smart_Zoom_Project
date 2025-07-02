import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    print("🔥 AppDelegate::applicationDidFinishLaunching çalıştı")
    super.applicationDidFinishLaunching(notification)
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      print("📨 open urls ile geldi: \(url)")

      // Flutter'a MethodChannel ile linki gönder
      if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "app.channel.shared.data",
                                           binaryMessenger: controller.engine.binaryMessenger)
        channel.invokeMethod("deep-link", arguments: url.absoluteString)
      }
    }
  }
}
