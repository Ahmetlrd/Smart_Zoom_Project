import Cocoa
import FlutterMacOS
import app_links

@main
class AppDelegate: FlutterAppDelegate {

  override func applicationDidFinishLaunching(_ notification: Notification) {
    print("🔥 AppDelegate::applicationDidFinishLaunching çalıştı")
    super.applicationDidFinishLaunching(notification)
  }

  override func application(_ application: NSApplication,
                            continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
    print("📦 continue userActivity geldi")

    guard let url = AppLinks.shared.getUniversalLink(userActivity) else {
      print("⛔️ getUniversalLink başarısız")
      return false
    }

    print("✅ AppLinks universal link: \(url.absoluteString)")
    AppLinks.shared.handleLink(link: url.absoluteString)

    return true
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      print("📨 open urls ile geldi: \(url)")
      AppLinks.shared.handleLink(link: url.absoluteString)
    }
  }
}
