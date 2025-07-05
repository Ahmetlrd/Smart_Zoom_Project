import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  var storedUrl: URL?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    print("🔥 AppDelegate::applicationDidFinishLaunching çalıştı")

    // Flutter MethodChannel tanımla
    if let controller = mainFlutterWindow?.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "smartzoom.macos.bookmark",
        binaryMessenger: controller.engine.binaryMessenger
      )

      channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "saveBookmark" {
          if let args = call.arguments as? [String: String],
             let path = args["path"] {
            let url = URL(fileURLWithPath: path)
            do {
              let bookmark = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
              UserDefaults.standard.set(bookmark, forKey: "zoom_bookmark")
              UserDefaults.standard.set(path, forKey: "zoom_folder_path")
              result(true)
            } catch {
              print("⚠️ Error saving bookmark: \(error)")
              result(false)
            }
          } else {
            result(false)
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Daha önce bookmark kayıtlıysa, erişimi başlat
    if let bookmarkData = UserDefaults.standard.data(forKey: "zoom_bookmark") {
      var isStale = false
      do {
        let url = try URL(resolvingBookmarkData: bookmarkData, options: [.withSecurityScope], bookmarkDataIsStale: &isStale)
        if url.startAccessingSecurityScopedResource() {
          print("🔓 Security scoped access GRANTED")
          storedUrl = url
        } else {
          print("❌ Failed to access security scoped resource")
        }
      } catch {
        print("⚠️ Error resolving bookmark: \(error)")
      }
    }

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
