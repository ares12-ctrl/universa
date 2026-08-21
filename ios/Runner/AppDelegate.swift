import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var blurEffectView: UIVisualEffectView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    setupScreenCaptureProtection()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // MARK: - iOS Privacy & Screen Recording Security (Adapted from MAXCLUB)
  private func setupScreenCaptureProtection() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    checkScreenCaptureStatus()
  }

  @objc private func screenCaptureChanged() {
    checkScreenCaptureStatus()
  }

  private func checkScreenCaptureStatus() {
    DispatchQueue.main.async {
      if UIScreen.main.isCaptured {
        self.showBlurOverlay()
      } else {
        self.hideBlurOverlay()
      }
    }
  }

  // Blur screen when app goes to background / app switcher
  override func applicationWillResignActive(_ application: UIApplication) {
    showBlurOverlay()
    super.applicationWillResignActive(application)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    if !UIScreen.main.isCaptured {
      hideBlurOverlay()
    }
    super.applicationDidBecomeActive(application)
  }

  private func showBlurOverlay() {
    guard blurEffectView == nil, let window = self.window else { return }
    let blurEffect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = window.bounds
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blurView.tag = 999111
    window.addSubview(blurView)
    self.blurEffectView = blurView
  }

  private func hideBlurOverlay() {
    blurEffectView?.removeFromSuperview()
    blurEffectView = nil
    if let window = self.window, let existing = window.viewWithTag(999111) {
      existing.removeFromSuperview()
    }
  }
}
